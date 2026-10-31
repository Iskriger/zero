import 'package:flutter/material.dart';
import 'package:goal_tracker/widgets/theme_aware_text.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Внешний вид
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              'Внешний вид',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Темная тема'),
            subtitle: const Text('Переключение между светлой и темной темой'),
            value: themeManager.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeManager.themeMode = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),

          const Divider(),

          // Управление данными
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              'Данные',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          // Заменяем старый пункт уведомлений:
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Уведомления'),
            subtitle: const Text('Настройка напоминаний'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                  context, '/notifications'); // <-- ВЕДЁМ НА НОВЫЙ ЭКРАН
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Резервное копирование'),
            subtitle: const Text('Экспорт и импорт данных'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция резервного копирования в разработке'),
                ),
              );
            },
          ),

          const Divider(),

          // О приложении
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              'О приложении',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const ThemeAwareText('О программе'),
            subtitle:
                const ThemeAwareText('Версия 1.4.0, разработчик и технологии'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Помощь'),
            subtitle: const Text('Как пользоваться приложением'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showHelpDialog(context);
            },
          ),

          const Divider(),

          // Информация
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zero - Goal Tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Курсовой проект по разработке мобильных приложений',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Технологии: Flutter, Dart, SQLite, Provider',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Как пользоваться приложением'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Основные функции:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Нажмите "+" для добавления новой цели'),
              Text('• Свайп вправо - отметить как выполненную'),
              Text('• Свайп влево - удалить цель'),
              Text('• Нажмите на цель для просмотра деталей'),
              SizedBox(height: 16),
              Text(
                'Категории и теги:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Используйте категории для организации целей'),
              Text('• Добавляйте теги для быстрого поиска'),
              Text('• Настройте приоритеты для важных задач'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
