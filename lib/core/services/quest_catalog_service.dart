import 'package:heros_journey/core/models/quest_models.dart';

abstract class QuestCatalogService {
  Future<List<Quest>> getAll();
}
