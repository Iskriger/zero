import 'package:flutter_test/flutter_test.dart';
import 'package:goal_tracker/models/goal.dart';
import 'package:goal_tracker/models/subtask.dart';

void main() {
  group('Goal', () {
    test('toMap/fromMap сохраняет все поля, включая подзадачи', () {
      final goal = Goal(
        id: 1,
        title: 'Выучить Flutter',
        description: 'Курсовая работа',
        category: 'Обучение',
        priority: 3,
        tags: ['dart', 'мобильное'],
        deadline: DateTime(2026, 12, 31),
        isCompleted: true,
        isArchived: false,
        createdAt: DateTime(2026, 1, 1),
        subtasks: [Subtask(title: 'Глава 1', isCompleted: true)],
      );

      final restored = Goal.fromMap(goal.toMap());

      expect(restored.id, 1);
      expect(restored.title, 'Выучить Flutter');
      expect(restored.description, 'Курсовая работа');
      expect(restored.category, 'Обучение');
      expect(restored.priority, 3);
      expect(restored.tags, ['dart', 'мобильное']);
      expect(restored.deadline, DateTime(2026, 12, 31));
      expect(restored.isCompleted, isTrue);
      expect(restored.isArchived, isFalse);
      expect(restored.createdAt, DateTime(2026, 1, 1));
      expect(restored.subtasks.length, 1);
      expect(restored.subtasks.first.title, 'Глава 1');
      expect(restored.subtasks.first.isCompleted, isTrue);
    });

    test('пустые теги корректно разворачиваются в пустой список', () {
      final goal = Goal(
        title: 'Без тегов',
        category: 'Работа',
        deadline: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 1, 1),
      );

      final restored = Goal.fromMap(goal.toMap());
      expect(restored.tags, isEmpty);
      expect(restored.subtasks, isEmpty);
      expect(restored.isCompleted, isFalse);
      expect(restored.isArchived, isFalse);
    });

    test('fromMap принимает legacy-формат (tags через запятую, bool как 0/1)', () {
      final goal = Goal.fromMap({
        'id': 7,
        'title': 'Старая запись',
        'category': 'Учеба',
        'priority': 1,
        'tags': 'один,два,,три',
        'deadline': '2026-05-01T00:00:00.000',
        'isCompleted': 1,
        'isArchived': 0,
        'createdAt': '2026-01-01T00:00:00.000',
      });

      expect(goal.tags, ['один', 'два', 'три']);
      expect(goal.isCompleted, isTrue);
      expect(goal.isArchived, isFalse);
      expect(goal.subtasks, isEmpty);
    });
  });

  group('Subtask', () {
    test('по умолчанию не выполнена', () {
      final subtask = Subtask(title: 'Сделать главу 1');
      expect(subtask.title, 'Сделать главу 1');
      expect(subtask.isCompleted, isFalse);
    });
  });
}
