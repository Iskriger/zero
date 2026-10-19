import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:goal_tracker/data/goals_store.dart';
import 'package:goal_tracker/data/shared_prefs_repository.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/subtask.dart';
import 'package:goal_tracker/utils/goal_sorter.dart';

/// Интеграционные тесты слоя данных:
/// GoalsStore + SharedPrefsRepository + SharedPreferences (mock).
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefsRepository.resetCacheForTesting();
    await SharedPrefsRepository.init();
    await SharedPrefsRepository.clearAll();
  });

  Goal makeGoal(
    String title, {
    int priority = 2,
    String category = 'Работа',
    DateTime? deadline,
    DateTime? createdAt,
    bool isCompleted = false,
    List<String> tags = const [],
  }) {
    return Goal(
      title: title,
      category: category,
      priority: priority,
      tags: tags,
      deadline: deadline ?? DateTime(2026, 12, 31),
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      isCompleted: isCompleted,
    );
  }

  group('GoalsStore ↔ репозиторий (сквозной сценарий)', () {
    test('полный жизненный цикл: add → complete → archive → restore → delete',
        () async {
      final store = GoalsStore();
      var notifications = 0;
      store.addListener(() => notifications++);

      // 1. Пустое хранилище.
      await store.load();
      expect(store.isLoaded, isTrue);
      expect(store.all, isEmpty);

      // 2. Добавляем цель — она должна сохраниться в хранилище.
      await store.addGoal(makeGoal('Написать тесты'));
      expect(store.all.length, 1);
      final savedId = store.all.first.id;
      expect(savedId, isNotNull);
      final fromRepo = await SharedPrefsRepository.getAllGoals();
      expect(fromRepo.single.title, 'Написать тесты');

      // 3. Отмечаем выполненной — completedAt фиксируется.
      final updated = await store.setCompleted(savedId!, true);
      expect(updated!.isCompleted, isTrue);
      expect(updated.completedAt, isNotNull);

      // 4. В архив и обратно.
      await store.setArchived(savedId, true);
      expect(store.activeGoals, isEmpty);
      expect(store.archivedGoals.length, 1);

      await store.setArchived(savedId, false);
      expect(store.activeGoals.length, 1);
      expect(store.archivedGoals, isEmpty);

      // 5. Безвозвратное удаление.
      await store.removeForever(savedId);
      expect(store.all, isEmpty);
      expect(await SharedPrefsRepository.getAllGoals(), isEmpty);

      // Store уведомлял подписчиков при каждом изменении.
      expect(notifications, greaterThanOrEqualTo(6));
    });

    test('addGoal генерирует уникальные последовательные id', () async {
      final store = GoalsStore();
      await store.addGoal(makeGoal('A'));
      await store.addGoal(makeGoal('B'));
      await store.addGoal(makeGoal('C'));

      final ids = store.all.map((g) => g.id).toList();
      expect(ids, [1, 2, 3]);
    });

    test('activeGoals сортированы: невыполненные по дедлайну, выполненные вниз',
        () async {
      final store = GoalsStore();
      await store.addGoal(makeGoal('Дальняя',
          deadline: DateTime(2027, 6, 1)));
      await store.addGoal(makeGoal('Ближняя',
          deadline: DateTime(2026, 3, 1)));
      await store.addGoal(makeGoal('Готово',
          deadline: DateTime(2026, 1, 5), isCompleted: true));

      final titles = store.activeGoals.map((g) => g.title).toList();
      expect(titles, ['Ближняя', 'Дальняя', 'Готово']);
    });

    test('подзадачи: toggleSubtask сохраняется между перезагрузками',
        () async {
      final store = GoalsStore();
      final goal = makeGoal('Курс');
      goal.subtasks.addAll([
        Subtask(title: 'Лекция 1'),
        Subtask(title: 'Лекция 2'),
        Subtask(title: 'Лекция 3'),
      ]);
      await store.addGoal(goal);
      final id = store.all.single.id!;

      await store.toggleSubtask(id, 1, true);
      expect(store.all.single.subtaskProgress, closeTo(1 / 3, 1e-9));

      // Новая «сессия» — данные читаются из хранилища заново.
      final store2 = GoalsStore();
      await store2.load();
      expect(store2.all.single.subtasks[1].isCompleted, isTrue);
      expect(store2.all.single.subtasks[0].isCompleted, isFalse);

      // Неверный индекс игнорируется без падения.
      await store2.toggleSubtask(id, 99, true);
      await store2.toggleSubtask(id, -1, true);
      expect(store2.all.single.subtasks.length, 3);
    });

    test('статистика через store соответствует содержимому хранилища',
        () async {
      final store = GoalsStore();
      final id1 = await store.addGoal(makeGoal('A', category: 'Спорт'))
          .then((_) => store.all.firstWhere((g) => g.title == 'A').id);
      await store.addGoal(makeGoal('B', priority: 3, category: 'Работа'));
      await store.addGoal(makeGoal('C', category: 'Работа'));
      await store.setCompleted(id1!, true);

      final stats = await store.getStatistics();
      expect(stats['total'], 3);
      expect(stats['completed'], 1);
      expect(stats['pending'], 2);
      expect(stats['completionRate'], 33);
      expect(stats['highPriority'], 1);
      expect(stats['categoryStats'], {'Спорт': 1, 'Работа': 2});
    });

    test('категории: прокси store ↔ репозиторий', () async {
      final store = GoalsStore();
      var cats = await store.getCategories();
      expect(cats, containsAll(['Учеба', 'Работа', 'Спорт']));

      await store.addCategory('Дом');
      cats = await store.getCategories();
      expect(cats, contains('Дом'));

      // Дубликат не добавляется.
      await store.addCategory('Дом');
      cats = await store.getCategories();
      expect(cats.where((c) => c == 'Дом').length, 1);

      await store.deleteCategory('Дом');
      cats = await store.getCategories();
      expect(cats, isNot(contains('Дом')));
    });

    test('демо-данные добавляются только при первом запуске', () async {
      // После clearAll ключ отсутствует — init() снова сеет демо-данные.
      SharedPreferences.setMockInitialValues({});
      SharedPrefsRepository.resetCacheForTesting();
      await SharedPrefsRepository.init();
      final first = await SharedPrefsRepository.getAllGoals();
      expect(first.length, 4);

      // Повторный init() не должен дублировать демо-данные.
      await SharedPrefsRepository.init();
      final second = await SharedPrefsRepository.getAllGoals();
      expect(second.length, 4);
    });

    test('битый JSON в хранилище не ронает загрузку (возвращается пустой список)',
        () async {
      SharedPreferences.setMockInitialValues({'goals_list_v3': '{не json'});
      SharedPrefsRepository.resetCacheForTesting();
      final store = GoalsStore();
      await store.load();
      expect(store.all, isEmpty);
      expect(store.isLoaded, isTrue);
    });
  });

  group('GoalSorter на реальных данных из хранилища', () {
    test('сортировка по приоритету/дедлайну/созданию', () async {
      final store = GoalsStore();
      await store.addGoal(makeGoal('низкий',
          priority: 1,
          deadline: DateTime(2026, 2, 1),
          createdAt: DateTime(2026, 1, 10)));
      await store.addGoal(makeGoal('высокий',
          priority: 3,
          deadline: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 1, 1)));
      await store.addGoal(makeGoal('средний',
          priority: 2,
          deadline: DateTime(2026, 3, 1),
          createdAt: DateTime(2026, 1, 20)));

      final goals = store.activeGoals;

      expect(
        GoalSorter.sort(goals, GoalSort.priority).map((g) => g.title).toList(),
        ['высокий', 'средний', 'низкий'],
      );
      expect(
        GoalSorter.sort(goals, GoalSort.deadline).map((g) => g.title).toList(),
        ['низкий', 'средний', 'высокий'],
      );
      expect(
        GoalSorter.sort(goals, GoalSort.created).map((g) => g.title).toList(),
        ['средний', 'низкий', 'высокий'],
      );
    });
  });
}
