// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/material.dart';

import '../models/goal.dart';

class StatisticsManager {
  static final StatisticsManager _instance = StatisticsManager._internal();
  factory StatisticsManager() => _instance;
  StatisticsManager._internal();

  Map<String, dynamic> getOverallStats(List<Goal> goals) {
    final activeGoals = goals.where((g) => !g.isArchived).toList();
    final completedGoals = activeGoals.where((g) => g.isCompleted).toList();
    final pendingGoals = activeGoals.where((g) => !g.isCompleted).toList();

    final totalGoals = activeGoals.length;
    final completedCount = completedGoals.length;
    final pendingCount = pendingGoals.length;

    final completionRate =
        totalGoals > 0 ? (completedCount / totalGoals * 100).round() : 0;

    final avgPriority = totalGoals > 0
        ? activeGoals.map((g) => g.priority).reduce((a, b) => a + b) /
            totalGoals
        : 0;

    final urgentGoals = activeGoals.where((g) => g.priority == 3).length;

    final now = DateTime.now();
    final overdueGoals =
        pendingGoals.where((g) => g.deadline.isBefore(now)).length;

    return {
      'total': totalGoals,
      'completed': completedCount,
      'pending': pendingCount,
      'completionRate': completionRate,
      'avgPriority': avgPriority.toStringAsFixed(1),
      'urgent': urgentGoals,
      'overdue': overdueGoals,
    };
  }

  List<Map<String, dynamic>> getCategoryStats(List<Goal> goals) {
    final activeGoals = goals.where((g) => !g.isArchived).toList();
    final categoryMap = <String, List<Goal>>{};
    print(
        '📊 Менеджер: Расчет статистики по категориям для ${goals.length} целей');

    if (goals.isEmpty) {
      print('📊 Менеджер: Нет целей для анализа');
      return [];
    }
    for (final goal in activeGoals) {
      categoryMap.putIfAbsent(goal.category, () => []);
      categoryMap[goal.category]!.add(goal);
    }

    final statsList = categoryMap.entries.map((entry) {
      final categoryGoals = entry.value;
      final completed = categoryGoals.where((g) => g.isCompleted).length;
      final pending = categoryGoals.length - completed;
      final completionRate = categoryGoals.isNotEmpty
          ? (completed / categoryGoals.length * 100).round()
          : 0;

      return {
        'category': entry.key,
        'total': categoryGoals.length,
        'completed': completed,
        'pending': pending,
        'completionRate': completionRate,
        'color': _getCategoryColor(entry.key),
      };
    }).toList();

    // Сортируем по убыванию общего количества целей
    statsList.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    return statsList;
  }

  Map<String, dynamic> getPriorityStats(List<Goal> goals) {
    final activeGoals = goals.where((g) => !g.isArchived).toList();

    final highGoals = activeGoals.where((g) => g.priority == 3).toList();
    final mediumGoals = activeGoals.where((g) => g.priority == 2).toList();
    final lowGoals = activeGoals.where((g) => g.priority == 1).toList();

    return {
      'high': _getPriorityData(highGoals, 'Высокий', Colors.red),
      'medium': _getPriorityData(mediumGoals, 'Средний', Colors.orange),
      'low': _getPriorityData(lowGoals, 'Низкий', Colors.green),
    };
  }

  List<Map<String, dynamic>> getWeeklyProgress(List<Goal> goals) {
    final now = DateTime.now();
    final weekData = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayGoals = goals.where((g) {
        final created =
            DateTime(g.createdAt.year, g.createdAt.month, g.createdAt.day);
        final day = DateTime(date.year, date.month, date.day);
        return created == day;
      }).toList();

      final completedGoals = dayGoals.where((g) => g.isCompleted).length;

      weekData.add({
        'day': _getDayName(date.weekday),
        'date': '${date.day}.${date.month}',
        'total': dayGoals.length,
        'completed': completedGoals,
        'completionRate': dayGoals.isNotEmpty
            ? (completedGoals / dayGoals.length * 100).round()
            : 0,
      });
    }

    return weekData;
  }

  List<Map<String, dynamic>> getMonthlyStats(List<Goal> goals) {
    final now = DateTime.now();
    final monthData = <Map<String, dynamic>>[];

    for (int i = 2; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      final monthGoals = goals.where((g) {
        return g.createdAt.isAfter(monthStart) &&
            g.createdAt.isBefore(monthEnd);
      }).toList();

      final completed = monthGoals.where((g) => g.isCompleted).length;
      final completionRate = monthGoals.isNotEmpty
          ? (completed / monthGoals.length * 100).round()
          : 0;

      monthData.add({
        'month': _getMonthName(monthStart.month),
        'year': monthStart.year,
        'total': monthGoals.length,
        'completed': completed,
        'completionRate': completionRate,
      });
    }

    return monthData;
  }

  Map<String, dynamic> getProductivityByHour(List<Goal> goals) {
    final completedGoals = goals.where((g) => g.isCompleted).toList();
    final hourMap = List<int>.filled(24, 0);

    for (final goal in completedGoals) {
      final hour = goal.createdAt.hour;
      hourMap[hour]++;
    }

    final maxCompleted = hourMap.isNotEmpty ? hourMap.reduce(max) : 0;
    final mostProductiveHour = hourMap.indexOf(maxCompleted);

    return {
      'hourData': hourMap,
      'mostProductiveHour': mostProductiveHour,
      'maxCompleted': maxCompleted,
    };
  }

  Map<String, dynamic> _getPriorityData(
      List<Goal> goals, String label, Color color) {
    final completed = goals.where((g) => g.isCompleted).length;
    final completionRate =
        goals.isNotEmpty ? (completed / goals.length * 100).round() : 0;

    return {
      'label': label,
      'total': goals.length,
      'completed': completed,
      'completionRate': completionRate,
      'color': color,
    };
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Учеба': Colors.blue,
      'Работа': Colors.green,
      'Личное': Colors.orange,
      'Спорт': Colors.red,
      'Хобби': Colors.purple,
      'Здоровье': Colors.teal,
      'Финансы': Colors.indigo,
    };

    return colors[category] ?? Colors.grey;
  }

  String _getDayName(int weekday) {
    const days = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    return days[weekday];
  }

  String _getMonthName(int month) {
    const months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек'
    ];
    return months[month - 1];
  }
}
