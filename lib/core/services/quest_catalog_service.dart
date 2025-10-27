import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/quest_catalog/models/quest_catalog_filter.dart';

abstract class QuestCatalogService {
  Future<List<Quest>> getAll();

  Stream<List<Quest>> getQuests({required QuestCatalogFilter filter});

  Future<Quest> createQuest({
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String createdBy,
  });

  Future<void> updateQuest({
    required String id,
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String updatedBy,
  });

  Future<void> toggleActive({
    required String id,
    required bool active,
    required String toggledBy,
  });
}
