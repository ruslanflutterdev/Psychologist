import 'package:heros_journey/core/models/quest_models.dart';

abstract class ChildQuestsService {
  Future<List<ChildQuest>> getAssigned(String childId);

  Future<List<ChildQuest>> getCompleted(String childId);

  Future<void> assignQuest({required String childId, required Quest quest});

  Future<void> completeQuest({
    required String childId,
    required String assignedId,
    required String comment,
    required String photoUrl,
    required DateTime completedAt,
  });
}
