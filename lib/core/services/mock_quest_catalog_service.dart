import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';
import 'package:heros_journey/features/quest_catalog/models/quest_catalog_filter.dart';

class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class MockQuestCatalogService implements QuestCatalogService {
  final Duration latency;
  final _controller = StreamController<List<Quest>>.broadcast();

  final List<Quest> _quests = [];
  bool _isInitialized = false;

  MockQuestCatalogService({this.latency = const Duration(milliseconds: 250)});

  void _initQuests() {
    if (_isInitialized) return;
    _quests.addAll([
      Quest(
        id: 's-1',
        title: '5 минут зарядки',
        description: 'Утренняя зарядка для тонуса тела.',
        type: QuestType.physical,
        xp: 10,
      ),
      Quest(
        id: 's-2',
        title: 'Прогулка 15 минут',
        description: 'Отвлечься и подышать свежим воздухом.',
        type: QuestType.physical,
        xp: 20,
      ),
      Quest(
        id: 'p-1',
        title: 'Мой личный квест',
        description: 'Создан психологом, доступен для редактирования.',
        type: QuestType.emotional,
        xp: 50,
        createdBy: 'MOCK_PSYCH_ID',
      ),
      Quest(
        id: 's-inactive',
        title: 'Архивный системный квест',
        description: 'Этот квест деактивирован.',
        type: QuestType.cognitive,
        xp: 5,
        active: false,
      ),
    ]);
    _isInitialized = true;
  }

  List<Quest> _filterList(List<Quest> list, QuestCatalogFilter filter) {
    Iterable<Quest> filtered = list;
    if (filter.onlyActive == true) {
      filtered = filtered.where((q) => q.active);
    }
    if (filter.type != null) {
      filtered = filtered.where((q) => q.type == filter.type);
    }
    if (filter.search != null && filter.search!.isNotEmpty) {
      final query = filter.search!.toLowerCase();
      filtered = filtered.where((q) => q.title.toLowerCase().contains(query));
    }
    final sorted = filtered.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<List<Quest>> getAll() async {
    await Future<void>.delayed(latency);
    _initQuests();
    return List.from(_quests);
  }

  @override
  Stream<List<Quest>> getQuests({required QuestCatalogFilter filter}) {
    return _controller.stream.map((list) => _filterList(list, filter));
  }

  void _pushUpdates() {
    _controller.add(List.from(_quests));
  }

  @override
  Future<Quest> createQuest({
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String createdBy,
  }) async {
    await Future<void>.delayed(latency);
    _initQuests();

    final newQuest = Quest(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      xp: xp,
      createdBy: createdBy,
    );

    _quests.insert(0, newQuest);
    _pushUpdates();
    return newQuest;
  }

  @override
  Future<void> updateQuest({
    required String id,
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String updatedBy,
  }) async {
    await Future<void>.delayed(latency);
    final index = _quests.indexWhere((q) => q.id == id);
    if (index == -1) return;

    final existing = _quests[index];
    if (existing.createdBy != updatedBy && existing.createdBy != 'SYSTEM') {
      throw PermissionDeniedException('Вы не можете редактировать этот квест.');
    }

    final updated = existing.copyWith(
      title: title,
      description: description,
      type: type,
      xp: xp,
      updatedAt: DateTime.now(),
    );

    _quests[index] = updated;
    _pushUpdates();
  }

  @override
  Future<void> toggleActive({
    required String id,
    required bool active,
    required String toggledBy,
  }) async {
    await Future<void>.delayed(latency);
    final index = _quests.indexWhere((q) => q.id == id);
    if (index == -1) return;

    final existing = _quests[index];
    if (existing.createdBy != toggledBy && existing.createdBy != 'SYSTEM') {
      throw PermissionDeniedException(
        'Вы не можете деактивировать этот квест.',
      );
    }
    final updated = existing.copyWith(
      active: active,
      updatedAt: DateTime.now(),
    );
    _quests[index] = updated;
    _pushUpdates();
  }
}
