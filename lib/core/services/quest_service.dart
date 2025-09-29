import 'package:heros_journey/core/models/quest.dart';

abstract class QuestService {
  Future<void> assignQuest({
    required String childId,
    required QuestDifficulty difficulty,
  });
}
