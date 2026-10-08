import 'package:goal_tracker/models/subtask.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Goal {
  @HiveField(0)
  int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final int priority;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final DateTime deadline;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  bool isArchived;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
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
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'tags': tags.join(','),
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      priority: map['priority'],
      tags: (map['tags'] as String)
          .split(',')
          .where((t) => t.isNotEmpty)
          .toList(),
      deadline: DateTime.parse(map['deadline']),
      isCompleted: map['isCompleted'] == 1,
      isArchived: map['isArchived'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
