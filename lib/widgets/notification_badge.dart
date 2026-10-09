import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/notification_manager.dart';

class NotificationBadge extends StatelessWidget {
  final Color? color;
  final double? size;

  const NotificationBadge({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<NotificationManager>(context, listen: true);
    final unreadCount = manager.unreadCount;

    if (unreadCount == 0) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          unreadCount > 9 ? '9+' : unreadCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size! * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
