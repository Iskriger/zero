import 'package:flutter/foundation.dart';
import 'shared_prefs_repository.dart';
import '../models/goal.dart';

/// Глобальное хранилище целей (ChangeNotifier).
///
/// Регистрируется в дереве виджетов через ChangeNotifierProvider (см. main.dart),
/// экраны получают его через context.watch<GoalsStore>() / context.read<>().
/// Все изменения идут через методы [GoalsStore], который обновляет состояние
/// и уведомляет подписчиков.
class GoalsStore extends ChangeNotifier {
  GoalsStore();

  List<Goal> _goals = [];
  bool _loaded = false;

  /// Все цели (активные + архивные), как лежат в репозитории.
  List<Goal> get all => List.unmodifiable(_goals);

  List<Goal> get activeGoals =>
      _goals.where((g) => !g.isArchived).toList()..sort(_defaultSort);

  List<Goal> get archivedGoals => _goals.where((g) => g.isArchived).toList();

  bool get isLoaded => _loaded;

  /// Загрузить/перезагрузить цели из хранилища.
  Future<void> load() async {
    _goals = await SharedPrefsRepository.getAllGoals();
    _loaded = true;
    notifyListeners();
  }

  static int _defaultSort(Goal a, Goal b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return a.deadline.compareTo(b.deadline);
  }

  Future<void> addGoal(Goal goal) async {
    await SharedPrefsRepository.addGoal(goal);
    await load();
  }

  Future<void> updateGoal(Goal goal) async {
    await SharedPrefsRepository.updateGoal(goal);
    await load();
  }

  Future<void> deleteGoal(int id) async {
    await SharedPrefsRepository.deleteGoal(id);
    await load();
  }

  Future<void> toggleSubtask(int goalId, int index, bool completed) async {
    await SharedPrefsRepository.toggleSubtask(goalId, index, completed);
    await load();
  }

  /// Отметить выполненной / снять отметку. Возвращает обновлённую цель
  /// (или null, если цель не найдена).
  Future<Goal?> setCompleted(int id, bool completed) async {
    await SharedPrefsRepository.markAsCompleted(id, completed);
    await load();
    final match = _goals.where((g) => g.id == id);
    return match.isEmpty ? null : match.first;
  }

  /// Архивировать или восстановить цель.
  Future<void> setArchived(int id, bool archived) async {
    await SharedPrefsRepository.archiveGoal(id, archived);
    await load();
  }

  /// Удалить безвозвратно.
  Future<void> removeForever(int id) async {
    await SharedPrefsRepository.removeGoal(id);
    await load();
  }

  // Категории проксируем в репозиторий, чтобы экранам не нужен был
  // прямой импорт SharedPrefsRepository.
  Future<List<String>> getCategories() =>
      SharedPrefsRepository.getCategories();

  Future<void> addCategory(String category) async {
    await SharedPrefsRepository.addCategory(category);
    notifyListeners();
  }

  Future<void> deleteCategory(String category) async {
    await SharedPrefsRepository.deleteCategory(category);
    notifyListeners();
  }

  Future<Map<String, dynamic>> getStatistics() =>
      SharedPrefsRepository.getStatistics();
}
