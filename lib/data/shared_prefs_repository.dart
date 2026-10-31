import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../models/subtask.dart';

class SharedPrefsRepository {
  static const String _goalsKey = 'goals_list_v3';
  static const String _categoriesKey = 'categories_list_v1';
  static SharedPreferences? _prefs;

  // Инициализация
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Добавляем тестовые данные если база пустая
    final goals = await getGoals();
    if (goals.isEmpty) {
      await _addSampleData();
    }
  }

  static Future<List<Goal>> getAllGoals() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_goalsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> goalsJson = jsonDecode(jsonString);
      return goalsJson.map((json) => _goalFromJson(json)).toList();
    } catch (e) {
      print('❌ Ошибка загрузки целей: $e');
      return [];
    }
  }

  static Future<List<Goal>> getActiveGoals() async {
    final allGoals = await getAllGoals();
    return allGoals.where((goal) => !goal.isArchived).toList();
  }

  static Future<List<Goal>> getArchivedGoals() async {
    final allGoals = await getAllGoals();
    print('📂 Всего целей: ${allGoals.length}');
    print('📂 Архивные цели: ${allGoals.where((g) => g.isArchived).length}');

    final archivedGoals = allGoals.where((goal) => goal.isArchived).toList();

    // Отладка
    for (var goal in archivedGoals) {
      print('📂 Архив: ${goal.title} (id: ${goal.id})');
    }

    return archivedGoals;
  }

  static Future<int> addGoal(Goal goal) async {
    final goals = await getAllGoals();

    // Генерируем ID
    int newId = 1;
    if (goals.isNotEmpty) {
      final maxId = goals.map((g) => g.id ?? 0).reduce((a, b) => a > b ? a : b);
      newId = maxId + 1;
    }

    goal.id = newId;
    goals.add(goal);
    await _saveGoals(goals);

    return newId;
  }

  static Future<void> updateGoal(Goal goal) async {
    final goals = await getAllGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);

    if (index != -1) {
      goals[index] = goal;
      await _saveGoals(goals);
    }
  }

  static Future<void> deleteGoal(int id) async {
    final goals = await getAllGoals();
    goals.removeWhere((g) => g.id == id);
    await _saveGoals(goals);
  }

  static Future<void> markAsCompleted(int id, bool completed) async {
    final goals = await getAllGoals();
    final index = goals.indexWhere((g) => g.id == id);

    if (index != -1) {
      goals[index].isCompleted = completed;
      await _saveGoals(goals);
    }
  }

  static Future<void> archiveGoal(int id, bool archived) async {
    final goals = await getAllGoals();
    final index = goals.indexWhere((g) => g.id == id);

    if (index != -1) {
      goals[index].isArchived = archived;
      await _saveGoals(goals);
    }
  }

  static Future<List<String>> getCategories() async {
    await _ensureInitialized();
    final categories = _prefs!.getStringList(_categoriesKey);

    if (categories == null || categories.isEmpty) {
      // Стандартные категории
      const defaultCategories = [
        'Учеба',
        'Работа',
        'Личное',
        'Спорт',
        'Хобби',
        'Здоровье',
        'Финансы'
      ];
      await _prefs!.setStringList(_categoriesKey, defaultCategories);
      return defaultCategories;
    }

    return categories;
  }

  static Future<void> addCategory(String category) async {
    final categories = await getCategories();
    if (!categories.contains(category)) {
      categories.add(category);
      await _prefs!.setStringList(_categoriesKey, categories);
    }
  }

  static Future<void> deleteCategory(String category) async {
    final categories = await getCategories();
    categories.remove(category);
    await _prefs!.setStringList(_categoriesKey, categories);
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    final goals = await getAllGoals();
    final activeGoals = goals.where((g) => !g.isArchived).toList();

    final total = activeGoals.length;
    final completed = activeGoals.where((g) => g.isCompleted).length;
    final pending = total - completed;
    final completionRate = total > 0 ? ((completed / total) * 100).round() : 0;

    // Статистика по категориям
    final categoryStats = <String, int>{};
    for (final goal in activeGoals) {
      categoryStats.update(
        goal.category,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Статистика по приоритетам
    final highPriority = activeGoals.where((g) => g.priority == 3).length;
    final mediumPriority = activeGoals.where((g) => g.priority == 2).length;
    final lowPriority = activeGoals.where((g) => g.priority == 1).length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'completionRate': completionRate,
      'categoryStats': categoryStats,
      'highPriority': highPriority,
      'mediumPriority': mediumPriority,
      'lowPriority': lowPriority,
    };
  }

  static Future<void> clearAll() async {
    await _prefs!.remove(_goalsKey);
    await _prefs!.remove(_categoriesKey);
  }

  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  static Future<void> _saveGoals(List<Goal> goals) async {
    await _ensureInitialized();
    final goalsJson = goals.map((goal) => _goalToJson(goal)).toList();
    final jsonString = jsonEncode(goalsJson);
    await _prefs!.setString(_goalsKey, jsonString);
  }

  static Future<void> _addSampleData() async {
    final now = DateTime.now();
    final sampleGoals = [
      Goal(
        title: 'Сдать курсовую работу',
        description: 'Завершить проект по Flutter',
        category: 'Учеба',
        priority: 3,
        tags: ['важно', 'учеба', 'проект'],
        deadline: now.add(Duration(days: 14)),
        createdAt: now.subtract(Duration(days: 7)),
        isCompleted: true,
      ),
      Goal(
        title: 'Купить продукты',
        description: 'Молоко, хлеб, фрукты',
        category: 'Личное',
        priority: 2,
        tags: ['быт', 'покупки'],
        deadline: now.add(Duration(days: 1)),
        createdAt: now.subtract(Duration(days: 2)),
        isCompleted: false,
      ),
      Goal(
        title: 'Заняться спортом',
        description: 'Тренировка в зале',
        category: 'Спорт',
        priority: 1,
        tags: ['здоровье', 'спорт'],
        deadline: now.add(Duration(days: 3)),
        createdAt: now,
        isCompleted: false,
      ),
      Goal(
        title: 'Прочитать книгу',
        description: 'Закончить "Чистый код"',
        category: 'Личное',
        priority: 2,
        tags: ['чтение', 'развитие'],
        deadline: now.add(Duration(days: 7)),
        createdAt: now.subtract(Duration(days: 5)),
        isCompleted: true,
      ),
    ];

    for (final goal in sampleGoals) {
      await addGoal(goal);
    }

    print('✅ Добавлено ${sampleGoals.length} тестовых целей');
  }

  static Map<String, dynamic> _goalToJson(Goal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'category': goal.category,
      'priority': goal.priority,
      'tags': goal.tags,
      'deadline': goal.deadline.toIso8601String(),
      'isCompleted': goal.isCompleted,
      'isArchived': goal.isArchived,
      'createdAt': goal.createdAt.toIso8601String(),
      'subtasks': goal.subtasks
          .map((s) => {
                'title': s.title,
                'isCompleted': s.isCompleted,
              })
          .toList(),
    };
  }

  static Goal _goalFromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      tags: List<String>.from(json['tags']),
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
      isArchived: json['isArchived'],
      createdAt: DateTime.parse(json['createdAt']),
      subtasks: (json['subtasks'] as List)
          .map((s) => Subtask(
                title: s['title'],
                isCompleted: s['isCompleted'],
              ))
          .toList(),
    );
  }

  static Future<dynamic> getGoals() async {}
}
