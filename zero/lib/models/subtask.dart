import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Subtask {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool isCompleted;

  Subtask({
    required this.title,
    this.isCompleted = false,
  });
}
