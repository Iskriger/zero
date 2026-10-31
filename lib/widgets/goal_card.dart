// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final Function(bool)? onToggleComplete;
  final Function()? onArchive;
  final Function()? onUnarchive;
  final bool isArchived;

  const GoalCard({
    super.key,
    required this.goal,
    this.onToggleComplete,
    this.onArchive,
    this.onUnarchive,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(8),
      color: goal.isCompleted
          ? (isDark ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50])
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: goal.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (!isArchived)
                  IconButton(
                    icon: Icon(
                      goal.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: goal.isCompleted
                          ? Colors.green
                          : theme.iconTheme.color,
                    ),
                    onPressed: () {
                      if (onToggleComplete != null) {
                        onToggleComplete!(!goal.isCompleted);
                      }
                    },
                  ),
              ],
            ),

            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.description!,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // КАТЕГОРИЯ И ПРИОРИТЕТ - ИСПРАВЛЕНО ДЛЯ ТЕМНОЙ ТЕМЫ
            Row(
              children: [
                _buildCategoryChip(goal.category, context),
                const SizedBox(width: 8),
                _buildPriorityChip(goal.priority, context),
                const Spacer(),
                Text(
                  '${goal.deadline.day}.${goal.deadline.month}.${goal.deadline.year}',
                  style: TextStyle(
                    color: goal.deadline.isBefore(DateTime.now())
                        ? Colors.red
                        : (isDark ? Colors.grey[400] : Colors.grey),
                    fontWeight: goal.deadline.isBefore(DateTime.now())
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),

            // ТЕГИ - ИСПРАВЛЕНО ДЛЯ ТЕМНОЙ ТЕМЫ
            if (goal.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: goal.tags
                    .map((tag) => _buildTagChip(tag, context))
                    .toList(),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isArchived && onArchive != null)
                  TextButton(
                    onPressed: onArchive,
                    child: Text(
                      'В архив',
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                if (isArchived && onUnarchive != null)
                  TextButton(
                    onPressed: onUnarchive,
                    child: Text(
                      'Восстановить',
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                Text(
                  'Создано: ${goal.createdAt.day}.${goal.createdAt.month}.${goal.createdAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getCategoryColor(category);

    return Chip(
      label: Text(
        category,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: isDark ? color.withOpacity(0.7) : color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildPriorityChip(int priority, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (label, color) = _getPriorityInfo(priority);

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: isDark ? color.withOpacity(0.7) : color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  Widget _buildTagChip(String tag, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Chip(
      label: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
      backgroundColor:
          isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
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

  (String, Color) _getPriorityInfo(int priority) {
    switch (priority) {
      case 1:
        return ('Низкий', Colors.green);
      case 2:
        return ('Средний', Colors.orange);
      case 3:
        return ('Высокий', Colors.red);
      default:
        return ('Средний', Colors.grey);
    }
  }
}
