import 'package:heros_journey/core/models/quest_models.dart';

class QuestCatalogFilter {
  final String? search;
  final QuestType? type;
  final bool? onlyActive;

  const QuestCatalogFilter({this.search, this.type, this.onlyActive});

  static const initial = QuestCatalogFilter(onlyActive: true);

  QuestCatalogFilter copyWith({
    String? search,
    QuestType? type,
    bool? onlyActive,
  }) {
    return QuestCatalogFilter(
      search: search,
      type: type,
      onlyActive: onlyActive,
    );
  }
}
