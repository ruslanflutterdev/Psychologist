import 'package:heros_journey/features/achievements/models/achievement_model.dart';

abstract class AchievementService {
  Stream<List<AchievementModel>> getMyAchievements();

  Future<AchievementModel> createAchievement({
    required String title,
    required String description,
    required String iconName,
    required String userId,
  });

  Future<void> attachToQuest({
    required String achievementId,
    required String questId,
  });

  Future<void> detachFromQuest({required String achievementId});
}
