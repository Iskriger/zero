import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/shared_prefs_repository.dart';
import '../utils/notification_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await SharedPrefsRepository.getStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationManager = Provider.of<NotificationManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStatisticsContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Тестовое уведомление для проверки
          notificationManager.showTestNotification();
        },
        tooltip: 'Тестовое уведомление',
        child: const Icon(Icons.notifications),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final total = _stats['total'] ?? 0;
    final completed = _stats['completed'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final completionRate = _stats['completionRate'] ?? 0;
    final categoryStats = _stats['categoryStats'] ?? {};
    final highPriority = _stats['highPriority'] ?? 0;
    final mediumPriority = _stats['mediumPriority'] ?? 0;
    final lowPriority = _stats['lowPriority'] ?? 0;

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'Нет данных для статистики',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Создайте несколько целей',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Создать цель'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Основные метрики
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Общая статистика',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard('Всего', total, Icons.flag, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard('Выполнено', completed, Icons.check_circle,
                          Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard(
                          'В процессе', pending, Icons.timer, Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Прогресс',
                          completionRate,
                          Icons.trending_up,
                          _getCompletionColor(completionRate),
                          isPercent: true),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Прогресс выполнения
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '📈 Прогресс выполнения',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: Colors.grey[200],
                    color: _getCompletionColor(completionRate),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completionRate% выполнено',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getCompletionColor(completionRate),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed из $total целей',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Статистика по категориям
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Распределение по категориям',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (categoryStats.isNotEmpty)
                    ...categoryStats.entries.map((entry) {
                      final category = entry.key;
                      final count = entry.value as int;
                      final percentage =
                          total > 0 ? ((count / total) * 100).round() : 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  '$count целей',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: total > 0 ? count / total : 0,
                                    backgroundColor: Colors.grey[200],
                                    color: _getCategoryColor(category),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(category),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Нет данных по категориям',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Статистика по приоритетам
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Приоритеты целей',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriorityRow('Высокий', highPriority, Colors.red, total),
                  _buildPriorityRow(
                      'Средний', mediumPriority, Colors.orange, total),
                  _buildPriorityRow('Низкий', lowPriority, Colors.green, total),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Быстрые действия
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Быстрые действия',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Новая цель'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_goal');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.archive),
                          label: const Text('Архив'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/archive');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color,
      {bool isPercent = false}) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                isPercent ? '$value%' : value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityRow(String label, int count, Color color, int total) {
    final percentage = total > 0 ? ((count / total) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.grey[200],
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
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
}
