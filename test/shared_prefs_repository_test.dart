import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goal_tracker/data/shared_prefs_repository.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/subtask.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefsRepository.resetCacheForTesting();
    await SharedPrefsRepository.init();
    // Чистим хранилище перед каждым тестом, чтобы тесты были независимыми.
    await SharedPrefsRepository.clearAll();
  });

  Goal makeGoal(String title, {int priority = 2, String category = 'Работа'}) {
    return Goal(
      title: title,
      category: category,
      priority: priority,
      deadline: DateTime(2026, 12, 31),
      createdAt: DateTime(2026, 1, 1),
    );
  }

  group('SharedPrefsRepository', () {
    test('init() при первом запуске добавляет демо-данные', () async {
      final goals = await SharedPrefsRepository.getAllGoals();
      expect(goals, isNotEmpty);
    });

    test('addGoal генерирует последовательные id', () async {
      final id1 = await SharedPrefsRepository.addGoal(makeGoal('Первая'));
      final id2 = await SharedPrefsRepository.addGoal(makeGoal('Вторая'));
      expect(id2, id1 + 1);

      final goals = await SharedPrefsRepository.getAllGoals();
      expect(goals.length, 2);
    });

    test('updateGoal сохраняет изменения', () async {
      final id = await SharedPrefsRepository.addGoal(makeGoal('Было'));
      final old = (await SharedPrefsRepository.getAllGoals()).first;
      // title в модели immutable — обновляем цель целиком.
      final goal = Goal(
        id: old.id,
        title: 'Стало',
        description: old.description,
        category: old.category,
        priority: old.priority,
        tags: old.tags,
        deadline: old.deadline,
        isCompleted: old.isCompleted,
        isArchived: old.isArchived,
        createdAt: old.createdAt,
        completedAt: old.completedAt,
        subtasks: old.subtasks,
      );
      await SharedPrefsRepository.updateGoal(goal);

      final updated = (await SharedPrefsRepository.getAllGoals())
          .firstWhere((g) => g.id == id);
      expect(updated.title, 'Стало');
    });

    test('deleteGoal удаляет цель', () async {
      final id = await SharedPrefsRepository.addGoal(makeGoal('Удалить'));
      await SharedPrefsRepository.deleteGoal(id);
      final goals = await SharedPrefsRepository.getAllGoals();
      expect(goals, isEmpty);
    });

    test('markAsCompleted и archiveGoal работают', () async {
      final id = await SharedPrefsRepository.addGoal(makeGoal('Цель'));

      await SharedPrefsRepository.markAsCompleted(id, true);
      await SharedPrefsRepository.archiveGoal(id, true);

      final archived = await SharedPrefsRepository.getArchivedGoals();
      expect(archived.length, 1);
      expect(archived.first.isCompleted, isTrue);

      final active = await SharedPrefsRepository.getActiveGoals();
      expect(active, isEmpty);
    });

    test('подзадачи корректно сохраняются и восстанавливаются', () async {
      final goal = makeGoal('С подзадачами');
      goal.subtasks.add(Subtask(title: 'Глава 1'));
      goal.subtasks.last.isCompleted = true;
      goal.subtasks.add(Subtask(title: 'Глава 2'));

      await SharedPrefsRepository.addGoal(goal);
      final restored = (await SharedPrefsRepository.getAllGoals()).first;

      expect(restored.subtasks.length, 2);
      expect(restored.subtasks[0].title, 'Глава 1');
      expect(restored.subtasks[0].isCompleted, isTrue);
      expect(restored.subtasks[1].isCompleted, isFalse);
    });

    test('getStatistics считает проценты и категории', () async {
      await SharedPrefsRepository.addGoal(makeGoal('A'))
          .then((id) => SharedPrefsRepository.markAsCompleted(id, true));
      await SharedPrefsRepository.addGoal(makeGoal('B', priority: 3));

      final stats = await SharedPrefsRepository.getStatistics();
      expect(stats['total'], 2);
      expect(stats['completed'], 1);
      expect(stats['completionRate'], 50);
      expect(stats['highPriority'], 1);
      expect(stats['categoryStats']['Работа'], 2);
    });

    test('категории: стандартный набор, добавление и удаление', () async {
      var categories = await SharedPrefsRepository.getCategories();
      expect(categories, contains('Учеба'));

      await SharedPrefsRepository.addCategory('Дом');
      categories = await SharedPrefsRepository.getCategories();
      expect(categories, contains('Дом'));

      await SharedPrefsRepository.deleteCategory('Дом');
      categories = await SharedPrefsRepository.getCategories();
      expect(categories, isNot(contains('Дом')));
    });

    test('clearAll очищает цели', () async {
      await SharedPrefsRepository.addGoal(makeGoal('Мусор'));
      await SharedPrefsRepository.clearAll();
      final goals = await SharedPrefsRepository.getAllGoals();
      expect(goals, isEmpty);
    });
  });
}
