// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/notification_manager.dart';

class NotificationBanner extends StatefulWidget {
  const NotificationBanner({super.key});

  @override
  _NotificationBannerState createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  bool _isVisible = false;
  AppNotification? _currentNotification;

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<NotificationManager>(context);

    // Слушаем новые уведомления
    if (manager.notifications.isNotEmpty) {
      final latest = manager.notifications.first;
      if (_currentNotification?.id != latest.id && !latest.isRead) {
        _currentNotification = latest;
        _isVisible = true;

        // Автоматически скрываем через 5 секунд
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _isVisible) {
            setState(() => _isVisible = false);
          }
        });
      }
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: _isVisible && _currentNotification != null
            ? GestureDetector(
                onTap: () {
                  setState(() => _isVisible = false);
                  manager.markAsRead(_currentNotification!.id);
                  // Можно добавить навигацию к деталям
                },
                child: Card(
                  elevation: 4,
                  color: _currentNotification!.color.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          _currentNotification!.icon,
                          color: _currentNotification!.color,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentNotification!.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _currentNotification!.color,
                                ),
                              ),
                              Text(
                                _currentNotification!.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() => _isVisible = false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
