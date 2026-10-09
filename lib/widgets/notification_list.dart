// ignore_for_file: use_super_parameters, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/notification_manager.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<NotificationManager>(context);
    final notifications = manager.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                manager.markAllAsRead();
              },
              tooltip: 'Пометить все как прочитанные',
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              manager.clearAll();
            },
            tooltip: 'Очистить все',
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет уведомлений',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Здесь появятся ваши уведомления',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id.toString()),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    manager.removeNotification(notification.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: notification.isRead
                        ? null
                        : notification.color.withOpacity(0.05),
                    child: ListTile(
                      leading: Icon(
                        notification.icon,
                        color: notification.color,
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.message),
                          const SizedBox(height: 4),
                          Text(
                            notification.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          notification.isRead
                              ? Icons.mark_email_unread
                              : Icons.mark_email_read,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          manager.markAsRead(notification.id);
                        },
                      ),
                      onTap: () {
                        manager.markAsRead(notification.id);
                        // Можно добавить дополнительное действие
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          manager.showTestNotification();
        },
        tooltip: 'Тестовое уведомление',
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
