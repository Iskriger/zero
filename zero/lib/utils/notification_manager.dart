import 'package:flutter/material.dart';
import '../models/goal.dart';

class NotificationManager with ChangeNotifier {
  // Синглтон
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Список активных уведомлений
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  // Добавить уведомление
  void addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    DateTime? expiresAt,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      isRead: false,
    );

    _notifications.insert(0, notification);
    notifyListeners();

    // Автоматическое удаление через 5 секунд (кроме важных)
    if (type != NotificationType.important) {
      Future.delayed(const Duration(seconds: 5), () {
        removeNotification(notification.id);
      });
    }
  }

  // Удалить уведомление
  void removeNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Пометить как прочитанное
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // Пометить все как прочитанные
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  // Очистить все уведомления
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Получить количество непрочитанных
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Проверка на просроченные цели
  void checkForDeadlines(List<Goal> goals) {
    final now = DateTime.now();

    for (final goal in goals) {
      if (goal.isCompleted || goal.isArchived) continue;

      final daysUntilDeadline = goal.deadline.difference(now).inDays;

      // Если осталось 1 день
      if (daysUntilDeadline == 1) {
        addNotification(
          title: 'Скоро дедлайн!',
          message: 'Завтра истекает срок цели: "${goal.title}"',
          type: NotificationType.warning,
        );
      }

      // Если просрочена
      if (goal.deadline.isBefore(now)) {
        addNotification(
          title: 'Цель просрочена!',
          message: 'Просрочена цель: "${goal.title}"',
          type: NotificationType.important,
        );
      }
    }
  }

  // Уведомление о новой цели
  void notifyGoalCreated(Goal goal) {
    addNotification(
      title: 'Цель создана!',
      message: 'Добавлена новая цель: "${goal.title}"',
      type: NotificationType.success,
    );
  }

  // Уведомление о выполненной цели
  void notifyGoalCompleted(Goal goal) {
    addNotification(
      title: 'Цель выполнена! 🎉',
      message: 'Поздравляем! Цель "${goal.title}" выполнена',
      type: NotificationType.success,
    );
  }

  // Тестовое уведомление
  void showTestNotification() {
    addNotification(
      title: 'Тестовое уведомление',
      message: 'Внутренние уведомления работают корректно!',
      type: NotificationType.info,
    );
  }
}

// Типы уведомлений
enum NotificationType {
  info, // Информационное (синий)
  success, // Успех (зеленый)
  warning, // Предупреждение (оранжевый)
  important, // Важное (красный)
}

// Модель уведомления
class AppNotification {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final DateTime? expiresAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
  });

  Color get color {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.important:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.important:
        return Icons.error;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} д назад';
    }
  }
}
