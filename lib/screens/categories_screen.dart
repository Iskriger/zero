import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Учеба', 'color': Colors.blue, 'count': 5},
      {'name': 'Работа', 'color': Colors.green, 'count': 3},
      {'name': 'Личное', 'color': Colors.orange, 'count': 4},
      {'name': 'Спорт', 'color': Colors.red, 'count': 2},
      {'name': 'Хобби', 'color': Colors.purple, 'count': 1},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: category['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(category['name'] as String),
              trailing: Text('${category['count']} целей'),
              onTap: () {
                // Редактирование категории
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCategory(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить категорию'),
          content: const TextField(
            decoration: InputDecoration(
              labelText: 'Название категории',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                // Сохранение категории
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
