import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';

class MockQuestCatalogService implements QuestCatalogService {
  final Duration latency;

  MockQuestCatalogService({this.latency = const Duration(milliseconds: 250)});

  static const _allQuests = <Quest>[
    Quest(id: 'q-p-1', title: '5 минут зарядки', type: QuestType.physical),
    Quest(id: 'q-p-2', title: 'Прогулка 15 минут', type: QuestType.physical),
    Quest(
      id: 'q-e-1',
      title: 'Дневник эмоций (3 записи)',
      type: QuestType.emotional,
    ),
    Quest(
      id: 'q-e-2',
      title: 'Практика дыхания 4-4-4',
      type: QuestType.emotional,
    ),
    Quest(
      id: 'q-c-1',
      title: 'Собрать пазл на 20 деталей',
      type: QuestType.cognitive,
    ),
    Quest(
      id: 'q-c-2',
      title: 'Прочитать короткий рассказ',
      type: QuestType.cognitive,
    ),
    Quest(
      id: 'q-s-1',
      title: 'Похвалить одноклассника',
      type: QuestType.social,
    ),
    Quest(
      id: 'q-s-2',
      title: 'Спросить “как дела?” у 2 друзей',
      type: QuestType.social,
    ),
    Quest(
      id: 'q-sp-1',
      title: '3 вещи, за которые благодарен',
      type: QuestType.spiritual,
    ),
    Quest(id: 'q-sp-2', title: 'Нарисовать мечту', type: QuestType.spiritual),
    Quest(
      id: 'q-inactive',
      title: 'Архивный квест',
      type: QuestType.physical,
      active: false,
    ),
  ];

  @override
  Future<List<Quest>> getAll() async {
    await Future<void>.delayed(latency);
    return _allQuests.where((q) => q.active).toList();
  }
}
