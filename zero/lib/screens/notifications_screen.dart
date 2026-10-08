// ignore_for_file: unused_local_variable, library_private_types_in_public_api, unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';
import '../utils/notification_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyReminders = true;
  bool _deadlineReminders = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _daysBeforeReminder = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Здесь можно загружать настройки из SharedPreferences
    setState(() {
      _notificationsEnabled = true;
      _dailyReminders = true;
      _deadlineReminders = true;
    });
  }

  Future<void> _saveSettings() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки уведомлений сохранены')),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );

    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final notificationManager = Provider.of<NotificationManager>(context);
    final notifications = notificationManager.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              notificationManager.showTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Тестовое уведомление отправлено')),
              );
            },
            tooltip: 'Тестовое уведомление',
          ),
        ],
      ),
      body: Column(
        children: [
          // Настройки уведомлений
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Включение/отключение уведомлений
                Card(
                  child: SwitchListTile(
                    title: const Text('Включить уведомления'),
                    subtitle: const Text('Получать напоминания о целях'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Типы уведомлений
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Типы уведомлений',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Напоминания о дедлайнах'),
                        subtitle: const Text(
                            'Уведомления за день до окончания срока'),
                        value: _deadlineReminders,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _deadlineReminders = value;
                                });
                                _saveSettings();
                              }
                            : null,
                      ),
                      SwitchListTile(
                        title: const Text('Ежедневные напоминания'),
                        subtitle: const Text('Регулярные уведомления о целях'),
                        value: _dailyReminders,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _dailyReminders = value;
                                });
                                _saveSettings();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Время ежедневных напоминаний
                Card(
                  child: ListTile(
                    title: const Text('Время напоминаний'),
                    subtitle: Text(_dailyReminderTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _notificationsEnabled && _dailyReminders
                        ? () => _selectTime(context)
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // За сколько дней напоминать
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Напоминать за',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDayButton(1, '1 день'),
                            const SizedBox(width: 8),
                            _buildDayButton(2, '2 дня'),
                            const SizedBox(width: 8),
                            _buildDayButton(3, '3 дня'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // История уведомлений
                if (notifications.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'История уведомлений',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...notifications.take(3).map((notification) {
                            return ListTile(
                              leading: Icon(
                                notification.icon,
                                color: notification.color,
                              ),
                              title: Text(notification.title),
                              subtitle: Text(notification.message),
                              trailing: Text(
                                notification.timeAgo,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          if (notifications.length > 3)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Показать все уведомления
                                },
                                child: const Text('Показать все'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Кнопки управления
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notificationManager.clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Все уведомления очищены')),
                      );
                    },
                    child: const Text('Очистить все'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Сохранить настройки'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayButton(int days, String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: _notificationsEnabled && _deadlineReminders
            ? () {
                setState(() {
                  _daysBeforeReminder = days;
                });
                _saveSettings();
              }
            : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: _daysBeforeReminder == days
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          side: BorderSide(
            color: _daysBeforeReminder == days
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
