import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';

abstract class ChildQuestsService {
  Future<List<ChildQuest>> getAssigned(
    String childId, {
    QuestTimeFilter? filter,
  });

  Future<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  });

  Future<void> assignQuest({required String childId, required Quest quest});

  Future<void> completeQuest({
    required String childId,
    required String assignedId,
    required String comment,
    required String photoUrl,
    required DateTime completedAt,
  });
}
