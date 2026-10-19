import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:goal_tracker/data/goals_store.dart';
import 'package:goal_tracker/data/shared_prefs_repository.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/screens/home_screen.dart';
import 'package:goal_tracker/screens/add_goal_screen.dart';
import 'package:goal_tracker/screens/archive_screen.dart';
import 'package:goal_tracker/screens/statistics_screen.dart';
import 'package:goal_tracker/screens/categories_screen.dart';
import 'package:goal_tracker/screens/notifications_screen.dart';
import 'package:goal_tracker/utils/notification_manager.dart';
import 'package:goal_tracker/utils/theme_manager.dart';

/// Интеграционные UI-тесты: экраны + GoalsStore + SharedPreferences (mock).
void main() {
  late GoalsStore store;
  late NotificationManager notifications;
  late ThemeManager theme;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefsRepository.resetCacheForTesting();
    await SharedPrefsRepository.init();
    await SharedPrefsRepository.clearAll();
    store = GoalsStore();
    notifications = NotificationManager();
    theme = ThemeManager();
  });

  Widget wrap(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => store),
          ChangeNotifierProvider(create: (_) => notifications),
          ChangeNotifierProvider(create: (_) => theme),
        ],
        child: MaterialApp(home: child),
      );

  Goal makeGoal(
    String title, {
    int priority = 2,
    String category = 'Работа',
    DateTime? deadline,
    bool isCompleted = false,
    bool isArchived = false,
    List<String> tags = const [],
  }) =>
      Goal(
        title: title,
        category: category,
        priority: priority,
        tags: tags,
        deadline: deadline ?? DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime(2026, 1, 1),
        isCompleted: isCompleted,
        isArchived: isArchived,
      );

  group('HomeScreen', () {
    testWidgets('показывает цели из хранилища', (tester) async {
      await store.addGoal(makeGoal('Цель раз'));
      await store.addGoal(makeGoal('Цель два'));

      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Цель раз'), findsOneWidget);
      expect(find.text('Цель два'), findsOneWidget);
    });

    testWidgets('пустое состояние при отсутствии целей', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Нет целей'), findsOneWidget);
      expect(find.text('Создать первую цель'), findsOneWidget);
    });

    testWidgets('отметка выполнения обновляет хранилище', (tester) async {
      await store.addGoal(makeGoal('Пометить'));
      final id = store.all.single.id!;

      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
      await tester.pumpAndSettle();

      final saved = (await SharedPrefsRepository.getAllGoals())
          .firstWhere((g) => g.id == id);
      expect(saved.isCompleted, isTrue);
      expect(saved.completedAt, isNotNull);
      // Появился снейкбар с предложением убрать в архив.
      expect(find.textContaining('выполнена'), findsOneWidget);
    });

    testWidgets('фильтр «Скрыть выполненные» убирает готовые цели',
        (tester) async {
      await store.addGoal(makeGoal('Активная'));
      await store.addGoal(makeGoal('Готовая', isCompleted: true));

      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Готовая'), findsOneWidget);

      await tester.tap(find.text('Скрыть выполненные'));
      await tester.pumpAndSettle();
      expect(find.text('Готовая'), findsNothing);
      expect(find.text('Активная'), findsOneWidget);
    });

    testWidgets('навигация к экрану добавления по FAB', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Новая цель'));
      await tester.pumpAndSettle();

      expect(find.byType(AddGoalScreen), findsOneWidget);
    });
  });

  group('AddGoalScreen ↔ HomeScreen', () {
    testWidgets('создание цели через форму появляется на главном экране',
        (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Новая цель'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Название цели'), 'Новая цель 42');
      await tester.tap(find.byTooltip('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Новая цель 42'), findsOneWidget);

      // И в хранилище записалась.
      final goals = await SharedPrefsRepository.getAllGoals();
      expect(goals.map((g) => g.title), contains('Новая цель 42'));
    });

    testWidgets('валидация: пустое название не сохраняется', (tester) async {
      await tester.pumpWidget(wrap(const AddGoalScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
      expect(await SharedPrefsRepository.getAllGoals(), isEmpty);
    });
  });

  group('ArchiveScreen', () {
    testWidgets('показывает архивные цели', (tester) async {
      await store.addGoal(makeGoal('В архиве', isArchived: true));
      await store.addGoal(makeGoal('На свободе'));

      await tester.pumpWidget(wrap(const ArchiveScreen()));
      await tester.pumpAndSettle();

      expect(find.text('В архиве'), findsOneWidget);
      expect(find.text('На свободе'), findsNothing);
    });
  });

  group('StatisticsScreen', () {
    testWidgets('отображает статистику по данным хранилища', (tester) async {
      await store.addGoal(makeGoal('A'));
      await store.addGoal(makeGoal('B'));
      final idA = store.all.firstWhere((g) => g.title == 'A').id!;
      await store.setCompleted(idA, true);

      await tester.pumpWidget(wrap(const StatisticsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets); // total
      expect(tester.takeException(), isNull);
    });
  });

  group('CategoriesScreen', () {
    testWidgets('рендерится без ошибок и показывает стандартные категории',
        (tester) async {
      await tester.pumpWidget(wrap(const CategoriesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Учеба'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsScreen', () {
    testWidgets('рендерится без ошибок', (tester) async {
      await tester.pumpWidget(wrap(const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
