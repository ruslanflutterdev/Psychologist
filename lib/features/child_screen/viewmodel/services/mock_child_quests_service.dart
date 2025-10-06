import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/viewmodel/services/child_quests_service.dart';

class MockChildQuestsService implements ChildQuestsService {
  final Duration latency;
  final Map<String, List<ChildQuest>> _assigned = {};
  final Map<String, List<ChildQuest>> _completed = {};

  MockChildQuestsService({this.latency = const Duration(milliseconds: 250)});

  @override
  Future<List<ChildQuest>> getAssigned(String childId) async {
    await Future<void>.delayed(latency);
    return List.unmodifiable(_assigned[childId] ?? const []);
  }

  @override
  Future<List<ChildQuest>> getCompleted(String childId) async {
    await Future<void>.delayed(latency);
    return List.unmodifiable(_completed[childId] ?? const []);
  }

  @override
  Future<void> assignQuest({
    required String childId,
    required Quest quest,
  }) async {
    await Future<void>.delayed(latency);
    final list = _assigned.putIfAbsent(childId, () => []);
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
    final assigned = _assigned[childId];
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
    final completed = _completed.putIfAbsent(childId, () => []);
    completed.insert(0, done);
  }
}
