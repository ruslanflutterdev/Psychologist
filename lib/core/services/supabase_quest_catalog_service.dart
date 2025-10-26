import 'dart:async';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/quest_catalog_service.dart';
import 'package:heros_journey/features/quest_catalog/models/quest_catalog_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

String _sphereFromType(QuestType t) {
  switch (t) {
    case QuestType.physical:
      return 'physical';
    case QuestType.emotional:
      return 'emotional';
    case QuestType.cognitive:
      return 'cognitive';
    case QuestType.social:
      return 'social';
    case QuestType.spiritual:
      return 'spiritual';
  }
}

QuestType _typeFromSphere(String? sphere) {
  switch ((sphere ?? 'general').toLowerCase()) {
    case 'physical':
      return QuestType.physical;
    case 'emotional':
      return QuestType.emotional;
    case 'cognitive':
      return QuestType.cognitive;
    case 'social':
      return QuestType.social;
    case 'spiritual':
      return QuestType.spiritual;
    default:
      return QuestType.physical;
  }
}

class SupabaseQuestCatalogService implements QuestCatalogService {
  final sb.SupabaseClient _supabase;

  SupabaseQuestCatalogService(this._supabase);

  Quest _mapRow(Map<String, dynamic> r) {
    return Quest(
      id: r['id'] as String,
      title: (r['title'] ?? '') as String,
      description: (r['description'] ?? '') as String,
      type: _typeFromSphere(r['sphere'] as String?),
      xp: (r['xp'] ?? 0) as int,
      active: (r['active'] ?? true) as bool,
      createdBy: (r['created_id'] ?? 'SYSTEM').toString(),
      updatedAt:
          DateTime.tryParse((r['updated_at'] ?? r['created_at']).toString()) ??
              DateTime.now(),
    );
  }

  List<String> get _columns => const [
        'id',
        'title',
        'description',
        'created_id',
        'active',
        'created_at',
        'updated_at',
        'xp',
        'sphere'
      ];

  @override
  Future<List<Quest>> getAll() async {
    final rows = await _supabase
        .from('quests')
        .select(_columns.join(','))
        .order('created_at', ascending: false);

    return (rows as List).cast<Map<String, dynamic>>().map(_mapRow).toList();
  }

  @override
  Stream<List<Quest>> getQuests({required QuestCatalogFilter filter}) {
    final stream =
        _supabase.from('quests').stream(primaryKey: ['id']).order('created_at');

    return stream.map((rows) {
      final list =
          rows.map<Map<String, dynamic>>((e) => e).map(_mapRow).toList();
      var filtered = list;
      if (filter.onlyActive == true) {
        filtered = filtered.where((q) => q.active).toList();
      }
      if (filter.type != null) {
        filtered = filtered.where((q) => q.type == filter.type).toList();
      }
      return filtered;
    });
  }

  @override
  Future<Quest> createQuest({
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String createdBy,
  }) async {
    final uid = _supabase.auth.currentUser?.id ?? createdBy;

    final inserted = await _supabase
        .from('quests')
        .insert({
          'title': title,
          'description': description,
          'created_id': uid,
          'active': true,
          'xp': xp,
          'sphere': _sphereFromType(type),
        })
        .select(_columns.join(','))
        .single();

    return _mapRow(inserted);
  }

  @override
  Future<Quest> updateQuest({
    required String id,
    required String title,
    required String description,
    required QuestType type,
    required int xp,
    required String updatedBy,
  }) async {
    final updated = await _supabase
        .from('quests')
        .update({
          'title': title,
          'description': description,
          'xp': xp,
          'sphere': _sphereFromType(type),
        })
        .eq('id', id)
        .select(_columns.join(','))
        .single();

    return _mapRow(updated);
  }

  @override
  Future<void> toggleActive({
    required String id,
    required bool active,
    required String toggledBy,
  }) async {
    await _supabase.from('quests').update({'active': active}).eq('id', id);
  }
}
