import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../data/shared_prefs_repository.dart'; // <-- НОВЫЙ РЕПОЗИТОРИЙ
import '../utils/notification_manager.dart';
import '../widgets/notification_banner.dart';
import '../widgets/notification_badge.dart';
import 'package:auto_size_text/auto_size_text.dart';





class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}




class _HomeScreenState extends State<HomeScreen> {
  List<Goal> _goals = [];
  bool _isLoading = true;
  final gru = AutoSizeGroup();

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
        backgroundColor: Colors.blue,
        title: const Text('Мои цели'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                autofocus: true,
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
            autofocus: true,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.pushNamed(context, '/add_goal');
              _refreshGoals();
            },
            autofocus: true,
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
                          const Icon(Icons.inbox, size: 64, color: Color.fromARGB(255, 203, 126, 53)),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет целей',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Добавьте свою первую цель',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/add_goal' );
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
        width: 280,
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
                  AutoSizeText(
                    'Zero: Goal Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),maxLines: 3,maxFontSize: 40, minFontSize: 10,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Версия 1.4.1',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: AutoSizeText('Главная', style: TextStyle(fontSize: 16),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru,),
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
              title:  AutoSizeText('Уведомления', style: TextStyle(fontSize:16),maxLines: 1,minFontSize: 5, maxFontSize: 24,group: gru,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: AutoSizeText('Архив', style: TextStyle(),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru,),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/archive');
                _refreshGoals();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: AutoSizeText('Статистика', style: TextStyle(),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/statistics');
              },
            ),/*
            ListTile(
              leading: const Icon(Icons.category),
              title: AutoSizeText('Категории', style: TextStyle(),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/categories');
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.settings),
              title: AutoSizeText('Настройки', style: TextStyle(),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru,),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: AutoSizeText('О приложении', style: TextStyle(),maxLines: 1, minFontSize: 5, maxFontSize: 24,group: gru,),
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
