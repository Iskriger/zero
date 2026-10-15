import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../data/goals_store.dart';
import '../utils/notification_manager.dart';
import '../widgets/notification_banner.dart';
import '../widgets/notification_badge.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'goal_detail_sheet.dart';
import '../main.dart' show appVersion;

/// Варианты сортировки списка целей.
enum GoalSort { deadline, priority, created }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gru = AutoSizeGroup();

  // Состояние фильтров/поиска живёт здесь, данные — в GoalsStore.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _categoryFilter;
  int? _priorityFilter;
  bool _hideCompleted = false;
  GoalSort _sort = GoalSort.deadline;

  @override
  void initState() {
    super.initState();
    // Загружаем цели один раз; дальше store сам уведомляет об изменениях.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<GoalsStore>();
      if (!store.isLoaded) store.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Применяет поиск, фильтры и сортировку к активным целям.
  List<Goal> _applyFilters(List<Goal> goals) {
    var result = goals.where((g) => !g.isArchived).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((g) {
        return g.title.toLowerCase().contains(q) ||
            (g.description?.toLowerCase().contains(q) ?? false) ||
            g.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }
    if (_categoryFilter != null) {
      result = result.where((g) => g.category == _categoryFilter).toList();
    }
    if (_priorityFilter != null) {
      result = result.where((g) => g.priority == _priorityFilter).toList();
    }
    if (_hideCompleted) {
      result = result.where((g) => !g.isCompleted).toList();
    }

    switch (_sort) {
      case GoalSort.deadline:
        result.sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return a.deadline.compareTo(b.deadline);
        });
      case GoalSort.priority:
        result.sort((a, b) {
          if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
          return b.priority.compareTo(a.priority);
        });
      case GoalSort.created:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _categoryFilter != null ||
      _priorityFilter != null ||
      _hideCompleted;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _categoryFilter = null;
      _priorityFilter = null;
      _hideCompleted = false;
    });
  }

  Future<void> _openAddGoal() async {
    await Navigator.pushNamed(context, '/add_goal');
    // Store уже обновлён на экране добавления — перезагрузка не нужна,
    // но на всякий случай синхронизируемся с хранилищем.
    if (mounted) context.read<GoalsStore>().load();
  }

  Future<void> _onToggleComplete(Goal goal, bool completed) async {
    final store = context.read<GoalsStore>();
    final updated = await store.setCompleted(goal.id!, completed);
    if (!mounted) return;

    if (completed && updated != null) {
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      notificationManager.notifyGoalCompleted(updated);

      // Предлагаем сразу отправить цель в архив.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Цель «${goal.title}» выполнена 🎉'),
            action: SnackBarAction(
              label: 'В архив',
              onPressed: () => store.setArchived(goal.id!, true),
            ),
          ),
        );
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Поиск по названию, описанию, тегам…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterRow(GoalsStore store) {
    final categories = store.all
        .where((g) => !g.isArchived)
        .map((g) => g.category)
        .toSet()
        .toList()
      ..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Фильтр категории — меню доступных категорий.
          PopupMenuButton<String?>(
            initialValue: _categoryFilter,
            onSelected: (value) =>
                setState(() => _categoryFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem<String?>(
                value: null,
                child: Text('Все категории'),
              ),
              ...categories.map(
                (c) => PopupMenuItem<String?>(value: c, child: Text(c)),
              ),
            ],
            child: Chip(
              avatar: const Icon(Icons.category, size: 16),
              label: Text(_categoryFilter ?? 'Категория'),
              visualDensity: VisualDensity.compact,
              selected: _categoryFilter != null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _categoryFilter != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<int?>(
            initialValue: _priorityFilter,
            onSelected: (value) =>
                setState(() => _priorityFilter = value),
            itemBuilder: (context) => const [
              PopupMenuItem<int?>(value: null, child: Text('Любой')),
              PopupMenuItem<int?>(value: 3, child: Text('Высокий')),
              PopupMenuItem<int?>(value: 2, child: Text('Средний')),
              PopupMenuItem<int?>(value: 1, child: Text('Низкий')),
            ],
            child: Chip(
              avatar: const Icon(Icons.flag, size: 16),
              label: Text(switch (_priorityFilter) {
                3 => 'Высокий',
                2 => 'Средний',
                1 => 'Низкий',
                _ => 'Приоритет',
              }),
              visualDensity: VisualDensity.compact,
              selected: _priorityFilter != null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _priorityFilter != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Скрыть выполненные'),
            visualDensity: VisualDensity.compact,
            selected: _hideCompleted,
            onSelected: (v) => setState(() => _hideCompleted = v),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<GoalSort>(
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: GoalSort.deadline,
                child: Text('По дедлайну'),
              ),
              PopupMenuItem(
                value: GoalSort.priority,
                child: Text('По приоритету'),
              ),
              PopupMenuItem(
                value: GoalSort.created,
                child: Text('По дате создания'),
              ),
            ],
            child: Chip(
              avatar: const Icon(Icons.sort, size: 16),
              label: Text(switch (_sort) {
                GoalSort.deadline => 'Дедлайн',
                GoalSort.priority => 'Приоритет',
                GoalSort.created => 'Создание',
              }),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.filter_alt_off, size: 16),
              label: const Text('Сбросить'),
              visualDensity: VisualDensity.compact,
              onPressed: _resetFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool filteredOut) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filteredOut ? Icons.search_off : Icons.inbox,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              filteredOut ? 'Ничего не найдено' : 'Нет целей',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(filteredOut
                ? 'Попробуйте изменить запрос или сбросить фильтры'
                : 'Добавьте свою первую цель'),
            const SizedBox(height: 16),
            if (filteredOut)
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Сбросить фильтры'),
              )
            else
              ElevatedButton.icon(
                onPressed: _openAddGoal,
                icon: const Icon(Icons.add),
                label: const Text('Создать первую цель'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final goals = _applyFilters(store.activeGoals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои цели'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
            onPressed: () => store.load(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildFilterRow(store),
              Expanded(
                child: !store.isLoaded
                    ? const Center(child: CircularProgressIndicator())
                    : goals.isEmpty
                        ? _buildEmptyState(store.activeGoals.isNotEmpty)
                        : RefreshIndicator(
                            onRefresh: store.load,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.only(bottom: 88, top: 4),
                              itemCount: goals.length,
                              itemBuilder: (context, index) {
                                final goal = goals[index];
                                return Dismissible(
                                  key: ValueKey('goal_${goal.id}'),
                                  direction: goal.isCompleted
                                      ? DismissDirection.endToStart
                                      : DismissDirection.none,
                                  background: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.archive,
                                        color: Colors.orange),
                                  ),
                                  onDismissed: (_) =>
                                      store.setArchived(goal.id!, true),
                                  child: GoalCard(
                                    goal: goal,
                                    onTap: (g) =>
                                        GoalDetailSheet.show(context, g),
                                    onToggleComplete: (completed) =>
                                        _onToggleComplete(goal, completed),
                                    onArchive: () =>
                                        store.setArchived(goal.id!, true),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          const NotificationBanner(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_goal_fab',
        onPressed: _openAddGoal,
        icon: const Icon(Icons.add),
        label: const Text('Новая цель'),
      ),
      drawer: Drawer(
        width: 280,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const AutoSizeText(
                    'Zero: Goal Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    maxFontSize: 40,
                    minFontSize: 10,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Версия $appVersion',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: AutoSizeText('Главная',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
              onTap: () => Navigator.pop(context),
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
              title: AutoSizeText('Уведомления',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: AutoSizeText('Архив',
                  style: const TextStyle(),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/archive');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: AutoSizeText('Статистика',
                  style: const TextStyle(),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/statistics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: AutoSizeText('Настройки',
                  style: const TextStyle(),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: AutoSizeText('О приложении',
                  style: const TextStyle(),
                  maxLines: 1,
                  minFontSize: 5,
                  maxFontSize: 24,
                  group: gru),
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
