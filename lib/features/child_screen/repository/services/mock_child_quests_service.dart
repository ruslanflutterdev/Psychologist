import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';

class DuplicateQuestException implements Exception {
  final String message;

  DuplicateQuestException(this.message);

  @override
  String toString() => 'DuplicateQuestException: $message';
}

class MockChildQuestsService implements ChildQuestsService {
  final Duration latency;
  final Map<String, List<ChildQuest>> assignedQuests = {};
  final Map<String, List<ChildQuest>> completedQuests = {};
  final _controller = StreamController<void>.broadcast();

  MockChildQuestsService({this.latency = const Duration(milliseconds: 250)}) {
    _setupInitialData();
  }

  void _setupInitialData() {
    completedQuests['1'] = [
      ChildQuest(
        id: 'c1',
        childId: '1',
        quest: Quest(
          id: 'q3',
          title: 'Дневник эмоций',
          type: QuestType.emotional,
        ),
        status: ChildQuestStatus.completed,
        childComment: 'Мне понравилось писать о своих чувствах.',
        photoUrl: 'https://picsum.photos/id/1/400/300',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    pushUpdates();
  }

  void pushUpdates() {
    _controller.add(null);
  }

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
  Stream<List<ChildQuest>> getAssigned(
    String childId, {
    QuestTimeFilter? filter,
  }) async* {
    yield (assignedQuests[childId] ?? [])
        .where((q) => _isQuestInFilter(q, filter))
        .toList();
    await for (final _ in _controller.stream) {
      final list = assignedQuests[childId] ?? [];
      yield list.where((q) => _isQuestInFilter(q, filter)).toList();
    }
  }

  @override
  Stream<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  }) async* {
    yield (completedQuests[childId] ?? [])
        .where((q) => _isQuestInFilter(q, filter))
        .toList();
    await for (final _ in _controller.stream) {
      final list = completedQuests[childId] ?? [];
      yield list.where((q) => _isQuestInFilter(q, filter)).toList();
    }
  }

  @override
  Future<void> assignQuest({
    required String childId,
    required Quest quest,
    required String assignedBy,
  }) async {
    await Future<void>.delayed(latency);
    final list = assignedQuests.putIfAbsent(childId, () => []);
    final isDuplicate = list.any((q) => q.quest.id == quest.id);
    if (isDuplicate) {
      throw DuplicateQuestException(
        'Квест "${quest.title}" уже назначен этому ребёнку.',
      );
    }

    final newQuest = ChildQuest(
      id: 'assign-${DateTime.now().millisecondsSinceEpoch}',
      childId: childId,
      quest: quest,
      status: ChildQuestStatus.assigned,
    );

    list.add(newQuest);
    pushUpdates();
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
    pushUpdates();
  }
}
