import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/subtask.dart';
import '../data/goals_store.dart';
import '../utils/notification_manager.dart';
import 'package:provider/provider.dart';

/// Экран добавления ЦЕЛИ. Если передан [existingGoal] — работает
/// в режиме редактирования (используется из GoalDetailSheet).
class AddGoalScreen extends StatefulWidget {
  final Goal? existingGoal;

  const AddGoalScreen({super.key, this.existingGoal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _newTagController;

  String _selectedCategory = 'Учеба';
  int _priority = 2;
  late DateTime _deadline;
  final List<String> _tags = [];
  final List<String> _categories = [];
  final List<TextEditingController> _subtaskControllers = [];
  bool _isSaving = false;

  bool get _isEditing => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;

    _titleController = TextEditingController(text: g?.title ?? '');
    _descriptionController =
        TextEditingController(text: g?.description ?? '');
    _newTagController = TextEditingController();
    _deadline = g?.deadline ?? DateTime.now().add(const Duration(days: 7));
    _priority = g?.priority ?? 2;
    _tags.addAll(g?.tags ?? const []);
    if (g != null) _selectedCategory = g.category;
    for (final s in g?.subtasks ?? const <Subtask>[]) {
      _subtaskControllers.add(TextEditingController(text: s.title));
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newTagController.dispose();
    for (final c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await context.read<GoalsStore>().getCategories();
    if (!mounted) return;
    setState(() {
      _categories.addAll(categories);
      if (!_isEditing && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  void _addTag(String raw) {
    final tag = raw.trim().toLowerCase().replaceAll('#', '');
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() => _tags.add(tag));
  }

  Future<void> _pickDeadline() async {
    // В режиме редактирования разрешаем выбирать и прошлые даты
    // (иначе нельзя «починить» просроченную цель).
    final firstDate = _isEditing
        ? DateTime.now().subtract(const Duration(days: 365))
        : DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline.isBefore(firstDate) ? firstDate : _deadline,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selectedDate != null) {
      setState(() => _deadline = selectedDate);
    }
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Подзадачи:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ...List.generate(_subtaskControllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskControllers[i],
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Подзадача ${i + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Удалить подзадачу',
                  onPressed: () => setState(() =>
                      _subtaskControllers.removeAt(i).dispose()),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(
                () => _subtaskControllers.add(TextEditingController())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Добавить подзадачу'),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Теги:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ..._tags.map(
              (tag) => InputChip(
                label: Text('#$tag'),
                onDeleted: () => setState(() => _tags.remove(tag)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Новый тег',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  _addTag(value);
                  _newTagController.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Добавить тег',
              icon: const Icon(Icons.add),
              onPressed: () {
                _addTag(_newTagController.text);
                _newTagController.clear();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать цель' : 'Добавить цель'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isEditing ? Icons.save : Icons.check),
            onPressed: _isSaving ? null : _saveGoal,
            tooltip: 'Сохранить',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название цели';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
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
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text('Приоритет:',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                      value: 1,
                      label: Text('Низкий'),
                      icon: Icon(Icons.low_priority)),
                  ButtonSegment(
                      value: 2,
                      label: Text('Средний'),
                      icon: Icon(Icons.flag)),
                  ButtonSegment(
                      value: 3,
                      label: Text('Высокий'),
                      icon: Icon(Icons.priority_high)),
                ],
                selected: {_priority},
                onSelectionChanged: (selection) =>
                    setState(() => _priority = selection.first),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                    'Дедлайн: ${_deadline.day}.${_deadline.month}.${_deadline.year}'),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDeadline,
              ),
              const Divider(height: 24),
              _buildTagsSection(),
              const Divider(height: 24),
              _buildSubtasksSection(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveGoal,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Сохранить изменения' : 'Добавить цель'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final subtasks = _subtaskControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => Subtask(title: t))
        .toList();

    final existing = widget.existingGoal;
    final goal = Goal(
      id: existing?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      category: _selectedCategory,
      priority: _priority,
      tags: List.of(_tags),
      deadline: _deadline,
      isCompleted: existing?.isCompleted ?? false,
      isArchived: existing?.isArchived ?? false,
      createdAt: existing?.createdAt ?? DateTime.now(),
      completedAt: existing?.completedAt,
      subtasks: subtasks,
    );

    final store = context.read<GoalsStore>();
    if (_isEditing) {
      // Сохраняем состояние выполненных подзадач по позиции.
      if (existing != null) {
        for (var i = 0;
            i < subtasks.length && i < existing.subtasks.length;
            i++) {
          subtasks[i].isCompleted = existing.subtasks[i].isCompleted;
        }
      }
      await store.updateGoal(goal);
    } else {
      await store.addGoal(goal);
      if (mounted) {
        final notificationManager =
            Provider.of<NotificationManager>(context, listen: false);
        notificationManager.notifyGoalCreated(goal);
      }
    }

    if (mounted) Navigator.pop(context);
  }
}
