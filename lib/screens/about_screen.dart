// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и версия
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.flag,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Zero - Goal Tracker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Версия 1.4.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Курсовой проект по разработке кроссплатформенного приложения',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Раздел о разработчике
            const Text(
              '👨‍💻 Разработчик',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        'Васильев Павел ИСИП 24',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Технологии
            const Text(
              'Технологии',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildTechCard(
                  'Flutter',
                  'UI фреймворк',
                  Colors.blue,
                  Icons.mobile_friendly,
                ),
                _buildTechCard(
                  'Dart',
                  'Язык программирования',
                  Colors.cyan,
                  Icons.code,
                ),
                _buildTechCard(
                  'SQLite',
                  'Локальная БД',
                  Colors.green,
                  Icons.storage,
                ),
                _buildTechCard(
                  'Provider',
                  'State management',
                  Colors.orange,
                  Icons.settings,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Особенности приложения
            const Text(
              'Возможности',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildFeatureTile(
                    'Создание целей с категориями', Icons.add_task),
                _buildFeatureTile('Приоритеты и теги', Icons.label),
                _buildFeatureTile('Подзадачи и описания', Icons.list),
                _buildFeatureTile('Архив целей', Icons.archive),
                _buildFeatureTile('Статистика выполнения', Icons.analytics),
                _buildFeatureTile('Темная/светлая тема', Icons.brightness_4),
                _buildFeatureTile(
                    'Минималистичный дизайн', Icons.design_services),
              ],
            ),

            const SizedBox(height: 24),

            // Контакты и ссылки
            const Text(
              'Контакты',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Документация Flutter'),
                      subtitle: const Text('Официальный сайт'),
                      onTap: () {
                        _launchUrl('https://flutter.dev');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTechCard(
      String title, String subtitle, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String text, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
