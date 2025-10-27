import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/testing/test_keys.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';
import 'package:heros_journey/features/child_screen/view/widgets/assigned_quest_tile.dart';
import 'package:heros_journey/features/child_screen/view/widgets/completed_quest_tile.dart';
import 'package:heros_journey/features/child_screen/view_model/widgets/quest_time_filter.dart';

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

  Widget _buildQuestList(List<ChildQuest> quests, Widget emptyWidget) {
    if (quests.isEmpty) {
      return emptyWidget;
    }
    return Column(
      key: Tk.assignedList,
      children: quests.map((e) => AssignedQuestTile(item: e)).toList(),
    );
  }

  Widget _buildCompletedList(List<ChildQuest> quests) {
    if (quests.isEmpty) {
      return Text(
        'Пока нет выполненных заданий ${_currentFilter.isActive ? "за выбранный период" : ""}',
      );
    }
    return Column(
      children: quests.map((e) => CompletedQuestTile(item: e)).toList(),
    );
  }

  Widget _buildAssignedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        StreamBuilder<List<ChildQuest>>(
          stream: widget.service.getAssigned(
            widget.childId,
            filter: _currentFilter,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return _buildLoadingState();
            }
            if (snap.hasError && !snap.hasData) {
              return _buildErrorState(snap.error);
            }
            final assigned = snap.data ?? [];
            return _buildQuestList(
              assigned,
              Text(
                'Нет назначенных квестов ${_currentFilter.isActive ? "за выбранный период" : ""}',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompletedSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Выполненные', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        StreamBuilder<List<ChildQuest>>(
          stream: widget.service.getCompleted(
            widget.childId,
            filter: _currentFilter,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return _buildLoadingState();
            }
            if (snap.hasError && !snap.hasData) {
              return _buildErrorState(snap.error);
            }

            final completed = snap.data ?? [];
            return _buildCompletedList(completed);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAssignedSection(context),
        const SizedBox(height: 16),
        _buildCompletedSection(context),
      ],
    );
  }
}
