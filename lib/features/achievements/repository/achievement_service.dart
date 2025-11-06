import 'package:heros_journey/features/achievements/models/achievement_model.dart';

abstract class AchievementService {
  Stream<List<AchievementModel>> getMyAchievements();

  Future<AchievementModel> createAchievement({
    required String title,
    required String description,
    required String iconName,
    required String userId,
  });

  Future<void> updateAchievement({
    required String achievementId,
    required String title,
    required String description,
    required String iconName,
    required bool active,
  });

  Future<void> deleteAchievement({required String achievementId});

  Future<void> attachToQuest({
    required String achievementId,
    required String questId,
  });

  Future<void> detachFromQuest({required String achievementId});
}
