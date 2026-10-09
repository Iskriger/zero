import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../data/shared_prefs_repository.dart'; // <-- ОБНОВЛЕНО
import '../utils/notification_manager.dart';
import 'package:provider/provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Учеба';
  int _priority = 2;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  final List<String> _tags = [];
  final List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await SharedPrefsRepository.getCategories();
    setState(() {
      _categories.addAll(categories);
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить цель'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGoal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название цели',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название цели';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Приоритет:'),
              Row(
                children: [
                  Radio(
                    value: 1,
                    // ignore: deprecated_member_use
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value as int;
                      });
                    },
                  ),
                  const Text('Низкий'),
                  Radio(
                    value: 2,
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value as int;
                      });
                    },
                  ),
                  const Text('Средний'),
                  Radio(
                    value: 3,
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value as int;
                      });
                    },
                  ),
                  const Text('Высокий'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                      'Дедлайн: ${_deadline.day}.${_deadline.month}.${_deadline.year}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _deadline = selectedDate;
                        });
                      }
                    },
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Теги:'),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('важно'),
                    selected: _tags.contains('важно'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tags.add('важно');
                        } else {
                          _tags.remove('важно');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('учеба'),
                    selected: _tags.contains('учеба'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tags.add('учеба');
                        } else {
                          _tags.remove('учеба');
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('работа'),
                    selected: _tags.contains('работа'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tags.add('работа');
                        } else {
                          _tags.remove('работа');
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        category: _selectedCategory,
        priority: _priority,
        tags: _tags,
        deadline: _deadline,
        createdAt: DateTime.now(),
      );

      await SharedPrefsRepository.addGoal(goal);

      // Уведомление о создании цели
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      notificationManager.notifyGoalCreated(goal);

      Navigator.pop(context);
    }
  }
}
