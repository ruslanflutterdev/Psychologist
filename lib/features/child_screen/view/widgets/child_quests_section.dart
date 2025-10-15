import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/testing/test_keys.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';
import 'package:heros_journey/features/child_screen/view/widgets/assigned_quest_tile.dart';
import 'package:heros_journey/features/child_screen/view/widgets/completed_quest_tile.dart';

class ChildQuestsSection extends StatelessWidget {
  final String childId;
  final ChildQuestsService service;
  final VoidCallback onRefreshAfterChange;

  const ChildQuestsSection({
    super.key,
    required this.childId,
    required this.service,
    required this.onRefreshAfterChange,
  });

  Future<(List<ChildQuest>, List<ChildQuest>)> _load() async {
    final assigned = await service.getAssigned(childId);
    final completed = await service.getCompleted(childId);
    return (assigned, completed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<ChildQuest>, List<ChildQuest>)>(
      future: _load(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Ошибка загрузки заданий: ${snap.error}'),
          );
        }

        final assigned = snap.data!.$1;
        final completed = snap.data!.$2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Текущие задания',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (assigned.isEmpty)
              const Text('Нет назначенных квестов')
            else
              Column(
                key: Tk.assignedList,
                children: assigned
                    .map((e) => AssignedQuestTile(item: e))
                    .toList(),
              ),

            const SizedBox(height: 16),
            Text('Выполненные', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (completed.isEmpty)
              const Text('Пока нет выполненных заданий')
            else
              ...completed.map((e) => CompletedQuestTile(item: e)),
          ],
        );
      },
    );
  }
}
