import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/testing/test_keys.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';
import 'package:heros_journey/features/child_screen/view/widgets/assigned_quest_tile.dart';
import 'package:heros_journey/features/child_screen/view/widgets/completed_quest_tile.dart';
import 'package:heros_journey/features/child_screen/view/widgets/quest_time_filter.dart';

class ChildQuestsSection extends StatefulWidget {
  final String childId;
  final ChildQuestsService service;
  final VoidCallback onRefreshAfterChange;

  const ChildQuestsSection({
    super.key,
    required this.childId,
    required this.service,
    required this.onRefreshAfterChange,
  });

  @override
  State<ChildQuestsSection> createState() => _ChildQuestsSectionState();
}

class _ChildQuestsSectionState extends State<ChildQuestsSection> {
  QuestTimeFilter _currentFilter = QuestTimeFilter.inactive;

  void _handleFilterChanged(QuestTimeFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
  }

  Future<(List<ChildQuest>, List<ChildQuest>)> _load() async {
    final assigned = await widget.service.getAssigned(
      widget.childId,
      filter: _currentFilter,
    );
    final completed = await widget.service.getCompleted(
      widget.childId,
      filter: _currentFilter,
    );
    return (assigned, completed);
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text('Ошибка загрузки заданий: $error'),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Текущие задания', style: Theme.of(context).textTheme.titleMedium),
        QuestTimeFilterDropdown(
          currentFilter: _currentFilter,
          onFilterChanged: _handleFilterChanged,
        ),
      ],
    );
  }

  Widget _buildAssignedQuests(List<ChildQuest> assigned) {
    if (assigned.isEmpty) {
      return Text(
        'Нет назначенных квестов ${_currentFilter.isActive ? "за выбранный период" : ""}',
      );
    }

    return Column(
      key: Tk.assignedList,
      children: assigned.map((e) => AssignedQuestTile(item: e)).toList(),
    );
  }

  Widget _buildCompletedQuests(
    BuildContext context,
    List<ChildQuest> completed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Выполненные', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (completed.isEmpty)
          Text(
            'Пока нет выполненных заданий ${_currentFilter.isActive ? "за выбранный период" : ""}',
          )
        else
          ...completed.map((e) => CompletedQuestTile(item: e)),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<ChildQuest> assigned,
    List<ChildQuest> completed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildAssignedQuests(assigned),
        const SizedBox(height: 16),
        _buildCompletedQuests(context, completed),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<ChildQuest>, List<ChildQuest>)>(
      future: _load(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _buildLoadingState();
        }
        if (snap.hasError) {
          return _buildErrorState(snap.error);
        }
        final assigned = snap.data!.$1;
        final completed = snap.data!.$2;
        return _buildContent(context, assigned, completed);
      },
    );
  }
}
