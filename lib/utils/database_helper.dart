// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Для Linux не используем SQLite
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw Exception('SQLite не поддерживается на этой платформе');
    }

    String path = join(await getDatabasesPath(), 'goals.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE goals(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT NOT NULL,
      priority INTEGER DEFAULT 2,
      tags TEXT,
      deadline TEXT NOT NULL,
      isCompleted INTEGER DEFAULT 0,
      isArchived INTEGER DEFAULT 0,
      createdAt TEXT NOT NULL
    )
  ''');

    // Добавляем тестовые данные
    await _addSampleData(db);
  }

  Future<List<Goal>> getGoalsByPeriod(DateTime start, DateTime end) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<List<Goal>> getCompletedGoalsByPeriod(
      DateTime start, DateTime end) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'isCompleted = 1 AND createdAt BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // Все методы должны проверять платформу
  Future<List<Goal>> getGoals({bool onlyActive = true}) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: onlyActive ? 'isArchived = 0' : null,
      orderBy: 'priority DESC, deadline ASC',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<void> _addSampleData(Database db) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    final testGoals = [
      {
        'title': 'Сдать курсовую работу',
        'description': 'Завершить проект по Flutter',
        'category': 'Учеба',
        'priority': 3,
        'tags': 'важно,учеба,проект',
        'deadline': nextWeek.toIso8601String(),
        'isCompleted': 1,
        'isArchived': 0,
        'createdAt': weekAgo.toIso8601String(),
      },
      {
        'title': 'Купить продукты',
        'description': 'Молоко, хлеб, фрукты',
        'category': 'Личное',
        'priority': 2,
        'tags': 'быт,покупки',
        'deadline': yesterday.toIso8601String(),
        'isCompleted': 0,
        'isArchived': 0,
        'createdAt': weekAgo.toIso8601String(),
      },
      {
        'title': 'Заняться спортом',
        'description': 'Тренировка в зале',
        'category': 'Спорт',
        'priority': 1,
        'tags': 'здоровье,спорт',
        'deadline': tomorrow.toIso8601String(),
        'isCompleted': 0,
        'isArchived': 0,
        'createdAt': now.toIso8601String(),
      },
      {
        'title': 'Прочитать книгу',
        'description': 'Закончить "Чистый код"',
        'category': 'Личное',
        'priority': 2,
        'tags': 'чтение,развитие',
        'deadline': nextWeek.toIso8601String(),
        'isCompleted': 1,
        'isArchived': 0,
        'createdAt': weekAgo.toIso8601String(),
      },
    ];

    for (final goal in testGoals) {
      await db.insert('goals', goal);
    }

    print('БД: Добавлено ${testGoals.length} тестовых целей');

    await db.insert('goals', {
      'title': 'Создать мобильное приложение',
      'description': 'Разработать приложение для трекинга целей',
      'category': 'Работа',
      'priority': 2,
      'tags': 'flutter,dart,проект',
      'deadline':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'isCompleted': 1,
      'isArchived': 0,
      'createdAt':
          DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    });

    await db.insert('goals', {
      'title': 'Прочитать книгу по программированию',
      'description': 'Закончить чтение "Чистый код"',
      'category': 'Личное',
      'priority': 1,
      'tags': 'чтение,развитие',
      'deadline': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'isCompleted': 0,
      'isArchived': 0,
      'createdAt':
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    });
  }

  // Добавить цель
  Future<int> insertGoal(Goal goal) async {
    Database db = await database;
    final id = await db.insert('goals', goal.toMap());

    // Обновляем ID цели
    goal.id = id;

    return id;
  }

  // Получить архивные цели
  Future<List<Goal>> getArchivedGoals() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'isArchived = 1',
    );
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  // Обновить цель
  Future<int> updateGoal(Goal goal) async {
    Database db = await database;
    final result = await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );

    return result;
  }

  // Удалить цель
  Future<int> deleteGoal(int id) async {
    Database db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Пометить как выполненную
  Future<int> markAsCompleted(int id, bool completed) async {
    Database db = await database;
    final result = await db.update(
      'goals',
      {'isCompleted': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  // Пометить как архивную
  Future<int> archiveGoal(int id, bool archived) async {
    Database db = await database;
    return await db.update(
      'goals',
      {'isArchived': archived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Статистика
  Future<Map<String, dynamic>> getStatistics() async {
    Database db = await database;

    final totalGoals = await db
        .rawQuery('SELECT COUNT(*) as count FROM goals WHERE isArchived = 0');

    final completedGoals = await db.rawQuery(
        'SELECT COUNT(*) as count FROM goals WHERE isCompleted = 1 AND isArchived = 0');

    final byCategory = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM goals WHERE isArchived = 0 GROUP BY category');

    return {
      'total': totalGoals.first['count'] as int,
      'completed': completedGoals.first['count'] as int,
      'byCategory': byCategory
          .map((e) => {'category': e['category'], 'count': e['count']})
          .toList(),
    };
  }

  Future<Goal?> getGoalById(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }
}
