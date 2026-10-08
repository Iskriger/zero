import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../data/shared_prefs_repository.dart'; // <-- НОВЫЙ РЕПОЗИТОРИЙ
import '../utils/notification_manager.dart';
import '../widgets/notification_banner.dart';
import '../widgets/notification_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await SharedPrefsRepository.getActiveGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });

      // Проверяем дедлайны
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      notificationManager.checkForDeadlines(goals);
    } catch (e) {
      print('!!Ошибка загрузки целей: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshGoals() {
    setState(() {
      _isLoading = true;
    });
    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои цели'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: NotificationBadge(),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGoals,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add_goal');
              _refreshGoals();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет целей',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Добавьте свою первую цель',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/add_goal');
                              _refreshGoals();
                            },
                            child: const Text('Создать первую цель'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _refreshGoals();
                        return Future.value();
                      },
                      child: ListView.builder(
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          return GoalCard(
                            goal: goal,
                            onToggleComplete: (completed) async {
                              await SharedPrefsRepository.markAsCompleted(
                                  goal.id!, completed);
                              _refreshGoals();

                              if (completed) {
                                final notificationManager =
                                    Provider.of<NotificationManager>(context,
                                        listen: false);
                                notificationManager.notifyGoalCompleted(goal);
                              }
                            },
                            onArchive: () async {
                              await SharedPrefsRepository.archiveGoal(
                                  goal.id!, true);
                              _refreshGoals();
                            },
                          );
                        },
                      ),
                    ),
          const NotificationBanner(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Goal Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Версия 1.4.0',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главная'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Stack(
                children: [
                  Icon(Icons.notifications),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: NotificationBadge(size: 16),
                  ),
                ],
              ),
              title: const Text('Уведомления'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Архив'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/archive');
                _refreshGoals();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Статистика'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/statistics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Категории'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}
