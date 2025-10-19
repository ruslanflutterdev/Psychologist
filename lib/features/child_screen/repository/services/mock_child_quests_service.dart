import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';

class MockChildQuestsService implements ChildQuestsService {
  final Duration latency;
  final Map<String, List<ChildQuest>> assignedQuests = {};
  final Map<String, List<ChildQuest>> completedQuests = {};

  MockChildQuestsService({this.latency = const Duration(milliseconds: 250)});

  bool _isQuestInFilter(ChildQuest quest, QuestTimeFilter? filter) {
    if (filter == null || !filter.isActive) return true;
    final questDate = quest.status == ChildQuestStatus.completed
        ? quest.completedAt
        : DateTime.now();
    if (questDate == null) return false;
    final from = filter.dateFrom?.subtract(const Duration(milliseconds: 1));
    final to = filter.dateTo
        ?.add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final isAfterFrom = from == null || questDate.isAfter(from);
    final isBeforeTo = to == null || questDate.isBefore(to);

    return isAfterFrom && isBeforeTo;
  }

  @override
  Future<List<ChildQuest>> getAssigned(
    String childId, {
    QuestTimeFilter? filter,
  }) async {
    await Future<void>.delayed(latency);
    final list = List<ChildQuest>.unmodifiable(
      assignedQuests[childId] ?? const <ChildQuest>[],
    );
    return list.where((q) => _isQuestInFilter(q, filter)).toList();
  }

  @override
  Future<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  }) async {
    await Future<void>.delayed(latency);
    final list = List<ChildQuest>.unmodifiable(
      completedQuests[childId] ?? const <ChildQuest>[],
    );
    return list.where((q) => _isQuestInFilter(q, filter)).toList();
  }

  @override
  Future<void> assignQuest({
    required String childId,
    required Quest quest,
  }) async {
    await Future<void>.delayed(latency);
    final list = assignedQuests.putIfAbsent(childId, () => []);
    list.add(
      ChildQuest(
        id: 'assign-$childId-${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        quest: quest,
        status: ChildQuestStatus.assigned,
      ),
    );
  }

  @override
  Future<void> completeQuest({
    required String childId,
    required String assignedId,
    required String comment,
    required String photoUrl,
    required DateTime completedAt,
  }) async {
    await Future<void>.delayed(latency);
    final assigned = assignedQuests[childId];
    if (assigned == null) return;
    final idx = assigned.indexWhere((e) => e.id == assignedId);
    if (idx < 0) return;

    final item = assigned.removeAt(idx);
    final done = item.copyWith(
      status: ChildQuestStatus.completed,
      childComment: comment,
      photoUrl: photoUrl,
      completedAt: completedAt,
    );
    final completed = completedQuests.putIfAbsent(childId, () => []);
    completed.insert(0, done);
  }
}
