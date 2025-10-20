import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';

class MockChildQuestsService implements ChildQuestsService {
  final Duration latency;
  final Map<String, List<ChildQuest>> assignedQuests = {};
  final Map<String, List<ChildQuest>> completedQuests = {};

  final _controller =
      StreamController<Map<String, List<ChildQuest>>>.broadcast();

  MockChildQuestsService({this.latency = const Duration(milliseconds: 250)}) {
    _setupInitialData();
  }

  void _setupInitialData() {
    assignedQuests['1'] = [
      const ChildQuest(
        id: 'a1',
        childId: '1',
        quest: Quest(
          id: 'q1',
          title: 'Утренняя зарядка',
          type: QuestType.physical,
        ),
        status: ChildQuestStatus.assigned,
      ),
      const ChildQuest(
        id: 'a2',
        childId: '1',
        quest: Quest(
          id: 'q2',
          title: 'Прочитать 5 страниц',
          type: QuestType.cognitive,
        ),
        status: ChildQuestStatus.assigned,
      ),
    ];
    completedQuests['1'] = [
      ChildQuest(
        id: 'c1',
        childId: '1',
        quest: const Quest(
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

    Future.delayed(const Duration(seconds: 5), () {
      assignedQuests['1']!.add(
        const ChildQuest(
          id: 'a3',
          childId: '1',
          quest: Quest(
            id: 'q4',
            title: 'Новый квест (Realtime)',
            type: QuestType.social,
          ),
          status: ChildQuestStatus.assigned,
        ),
      );
      pushUpdates();
    });
  }

  void pushUpdates() {
    _controller.add({
      'assigned': assignedQuests['1'] ?? [],
      'completed': completedQuests['1'] ?? [],
    });
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
  }) {
    return _controller.stream.map((maps) {
      final list = maps['assigned'] ?? [];
      return list.where((q) => _isQuestInFilter(q, filter)).toList();
    });
  }

  @override
  Stream<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  }) {
    return _controller.stream.map((maps) {
      final list = maps['completed'] ?? [];
      return list.where((q) => _isQuestInFilter(q, filter)).toList();
    });
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
        id: 'assign-${DateTime.now().millisecondsSinceEpoch}',
        childId: childId,
        quest: quest,
        status: ChildQuestStatus.assigned,
      ),
    );
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
