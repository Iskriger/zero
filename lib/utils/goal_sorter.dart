import '../models/goal.dart';

/// Варианты сортировки списка целей.
enum GoalSort { deadline, priority, created }

/// Единая логика сортировки целей (используется в GoalsStore и на главном экране).
class GoalSorter {
  const GoalSorter._();

  /// Отсортированная копия списка. Выполненные всегда в конце
  /// (кроме режима «по дате создания», где решает только createdAt).
  static List<Goal> sort(List<Goal> goals, GoalSort mode) {
    final result = List<Goal>.from(goals);
    switch (mode) {
      case GoalSort.deadline:
        result.sort(_byDeadline);
      case GoalSort.priority:
        result.sort((a, b) {
          final byDone = a.isCompleted ? 1 : (b.isCompleted ? -1 : 0);
          if (byDone != 0) return byDone;
          return b.priority.compareTo(a.priority);
        });
      case GoalSort.created:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  static int _byDeadline(Goal a, Goal b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return a.deadline.compareTo(b.deadline);
  }
}
