import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../data/shared_prefs_repository.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Goal> _archivedGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedGoals();
  }

  Future<void> _loadArchivedGoals() async {
    try {
      final goals = await SharedPrefsRepository.getArchivedGoals();
      setState(() {
        _archivedGoals = goals;
        _isLoading = false;
      });
      print('Загружено архивных целей: ${goals.length}');
    } catch (e) {
      print('!!Ошибка загрузки архива!!: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshGoals() {
    setState(() {
      _isLoading = true;
    });
    _loadArchivedGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архив целей'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGoals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _archivedGoals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Архив пуст',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Заархивированные цели появятся здесь',
                        style: TextStyle(color: Colors.grey[500]),
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
                    itemCount: _archivedGoals.length,
                    itemBuilder: (context, index) {
                      final goal = _archivedGoals[index];
                      return GoalCard(
                        goal: goal,
                        isArchived: true,
                        onUnarchive: () async {
                          await SharedPrefsRepository.archiveGoal(
                              goal.id!, false);
                          _refreshGoals();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Цель "${goal.title}" восстановлена'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
