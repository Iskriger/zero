import 'subtask.dart';

/// Модель цели. Сериализация — через SharedPreferences (JSON),
/// см. lib/data/shared_prefs_repository.dart
class Goal {
  int? id;
  final String title;
  final String? description;
  final String category;
  final int priority;
  final List<String> tags;
  final DateTime deadline;
  bool isCompleted;
  bool isArchived;
  final DateTime createdAt;
  DateTime? completedAt;
  final List<Subtask> subtasks;

  Goal({
    this.id,
    required this.title,
    this.description,
    required this.category,
    this.priority = 2,
    this.tags = const [],
    required this.deadline,
    this.isCompleted = false,
    this.isArchived = false,
    required this.createdAt,
    this.completedAt,
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

  /// Прогресс по подзадачам: от 0.0 до 1.0 (1.0, если подзадач нет).
  double get subtaskProgress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return subtasks.where((s) => s.isCompleted).length / subtasks.length;
  }

  /// Осталось дней до дедлайна (отрицательное — просрочено).
  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  bool get isOverdue => !isCompleted && deadline.isBefore(DateTime.now());

  /// Человекочитаемая подсказка о сроке: «просрочено на N дн.»,
  /// «сегодня», «завтра», «через N дн.» или дата для дальних сроков.
  String get deadlineHint {
    if (isCompleted) return 'выполнено';
    final days = daysLeft;
    if (days < -1) return 'просрочено на ${-days} дн.';
    if (days < 0) return 'просрочено';
    if (days == 0) return 'сегодня';
    if (days == 1) return 'завтра';
    if (days <= 30) return 'через $days дн.';
    return '${deadline.day}.${deadline.month}.${deadline.year}';
  }

  /// Внутренний формат хранилища (SharedPreferences, JSON).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'tags': tags,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'];
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: map['priority'] as int? ?? 2,
      tags: rawTags == null
          ? const []
          : (rawTags is List
              ? rawTags.map((t) => t.toString()).toList()
              : rawTags
                  .toString()
                  .split(',')
                  .where((t) => t.isNotEmpty)
                  .toList()),
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      isArchived: map['isArchived'] == true || map['isArchived'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString())
          : null,
      subtasks: ((map['subtasks'] as List?) ?? [])
          .map((s) => Subtask.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList(),
    );
  }
}
