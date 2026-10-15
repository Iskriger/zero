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
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

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
      'subtasks': subtasks
          .map((s) => {'title': s.title, 'isCompleted': s.isCompleted})
          .toList(),
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
      subtasks: ((map['subtasks'] as List?) ?? [])
          .map((s) => Subtask(
                title: s['title'],
                isCompleted: s['isCompleted'] == true,
              ))
          .toList(),
    );
  }
}
