import 'package:flutter/material.dart';
import 'package:goal_tracker/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_goal_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/about_screen.dart';
import 'screens/notifications_screen.dart';
import 'utils/theme_manager.dart';
import 'utils/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Goal Tracker',
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/add_goal': (context) => const AddGoalScreen(),
              '/archive': (context) => const ArchiveScreen(),
              '/statistics': (context) => const StatisticsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/about': (context) => const AboutScreen(),
              '/notifications': (context) => const NotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}
