import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../data/goals_store.dart';
import 'add_goal_screen.dart';

/// Bottom sheet с деталями цели: чек-лист подзадач, теги, кнопки
/// «Редактировать», «В архив / Восстановить» и удаление.
class GoalDetailSheet extends StatelessWidget {
  final int goalId;

  const GoalDetailSheet({super.key, required this.goalId});

  /// Удобный вход: показать шторку для конкретной цели.
  static Future<void> show(BuildContext context, Goal goal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => GoalDetailSheet(goalId: goal.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalsStore>();
    final matches = store.all.where((g) => g.id == goalId);
    if (matches.isEmpty) {
      // Цель удалена/архивирована без перерисовки — закрываем шторку.
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Navigator.of(context).maybePop());
      return const SizedBox.shrink();
    }
    final goal = matches.first;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              goal.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (goal.description != null &&
                goal.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(goal.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text(goal.category), visualDensity: VisualDensity.compact),
                Chip(
                  label: Text('Приоритет: ${goal.priority}'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  avatar: Icon(
                    goal.isOverdue ? Icons.warning : Icons.event,
                    size: 16,
                    color: goal.isOverdue ? Colors.red : null,
                  ),
                  label: Text(goal.deadlineHint),
                  visualDensity: VisualDensity.compact,
                ),
                ...goal.tags.map((t) => Chip(
                      label: Text('#$t'),
                      visualDensity: VisualDensity.compact,
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // ЧЕК-ЛИСТ ПОДЗАДАЧ
            if (goal.subtasks.isNotEmpty) ...[
              Row(
                children: [
                  Text('Подзадачи',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${goal.subtasks.where((s) => s.isCompleted).length}/${goal.subtasks.length}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.subtaskProgress,
                  minHeight: 6,
                  color: theme.colorScheme.primary,
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < goal.subtasks.length; i++)
                    CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(goal.subtasks[i].title),
                      value: goal.subtasks[i].isCompleted,
                      onChanged: (v) => store.toggleSubtask(
                          goal.id!, i, v ?? false),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // ДЕЙСТВИЯ
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddGoalScreen(existingGoal: goal),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Изменить'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await store.setArchived(goal.id!, !goal.isArchived);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(goal.isArchived
                        ? Icons.unarchive
                        : Icons.archive),
                    label: Text(
                        goal.isArchived ? 'Вернуть' : 'В архив'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Удалить цель?'),
                    content: Text(
                        'Цель «${goal.title}» будет удалена безвозвратно.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Отмена'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await store.removeForever(goal.id!);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Удалить навсегда',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
