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
import 'package:package_info_plus/package_info_plus.dart';
import 'utils/theme_manager.dart';
import 'utils/notification_manager.dart';
import 'data/goals_store.dart';
import 'data/shared_prefs_repository.dart';

/// Глобальный доступ к версии приложения (обновляется в main()).
/// Используется в шапке drawer'а, настройках и «О приложении»,
/// чтобы номер версии не приходилось править в трёх местах.
String appVersion = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем хранилище до запуска UI, чтобы первый кадр
  // не зависел от ленивой инициализации в репозитории.
  await SharedPrefsRepository.init();

  // Реальная версия из pubspec.yaml — больше не хардкодим её в виджетах.
  final info = await PackageInfo.fromPlatform();
  appVersion = info.version;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()..restore()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
        ChangeNotifierProvider(create: (_) => GoalsStore()..load()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zero: Goal Tracker',
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
