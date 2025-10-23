import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart'
    show ChildQuestsService;
import 'package:heros_journey/features/child_screen/repository/services/mock_child_quests_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseChildQuestsService implements ChildQuestsService {
  final sb.SupabaseClient _supabase;

  SupabaseChildQuestsService(this._supabase);

  @override
  Stream<List<ChildQuest>> getAssigned(
    String childId, {
    QuestTimeFilter? filter,
  }) {
    return Stream.fromFuture(_fetchAssigned(childId: childId));
  }

  @override
  Stream<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  }) {
    return Stream.fromFuture(_fetchCompleted(childId: childId));
  }

  @override
  Future<void> assignQuest({
    required String childId,
    required Quest quest,
    required String assignedBy,
  }) async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) {
        throw AuthException('UNAUTHORIZED', 'Нет активной сессии');
      }
      if (!_isUuid(childId)) {
        throw AuthException('INVALID_ARG', 'childId не uuid: $childId');
      }
      if (!_isUuid(quest.id)) {
        throw AuthException('INVALID_ARG', 'quest.id не uuid: ${quest.id}');
      }

      final existing = await _supabase
          .from('child_quests')
          .select('id, status')
          .eq('child_id', childId)
          .eq('quest_id', quest.id)
          .maybeSingle();

      if (existing != null) {
        throw DuplicateQuestException('Квест уже назначен этому ребёнку');
      }

      await _supabase.from('child_quests').insert({
        'child_id': childId,
        'quest_id': quest.id,
        'status': 'assigned',
        'assigned_by': uid,
      });
    } on DuplicateQuestException {
      rethrow;
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB', 'Ошибка назначения квеста: ${e.message}');
    } catch (e) {
      throw AuthException(
          'UNKNOWN', 'Ошибка назначения квеста: ${e.toString()}');
    }
  }

  @override
  Future<void> completeQuest({
    required String childId,
    required String assignedId,
    required String comment,
    required String photoUrl,
    required DateTime completedAt,
  }) async {
    Future<void> updateWithStatus(String st) async {
      final updated = await _supabase
          .from('child_quests')
          .update({
            'status': st,
            'child_comment': comment,
            'photo_url': photoUrl,
            'completed_at': completedAt.toIso8601String(),
          })
          .eq('id', assignedId)
          .eq('child_id', childId)
          .select('id')
          .maybeSingle();
      if (updated == null) {
        throw AuthException(
            'NOT_FOUND', 'Запись задания не найдена или нет доступа.');
      }
    }

    try {
      if (!_isUuid(childId)) {
        throw AuthException('INVALID_ARG', 'childId не uuid: $childId');
      }
      if (!_isUuid(assignedId)) {
        throw AuthException('INVALID_ARG', 'assignedId не uuid: $assignedId');
      }

      try {
        await updateWithStatus('completed');
      } on sb.PostgrestException catch (e) {
        final msg = (e.message).toLowerCase();
        if (msg.contains('invalid input value for enum') ||
            msg.contains('invalid input syntax for type')) {
          await updateWithStatus('verified');
        } else {
          rethrow;
        }
      }
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB', 'Ошибка завершения квеста: ${e.message}');
    } catch (e) {
      throw AuthException(
          'UNKNOWN', 'Ошибка завершения квеста: ${e.toString()}');
    }
  }

  Future<List<ChildQuest>> _fetchAssigned({required String childId}) async {
    final rows = await _selectRows(childId);
    return rows
        .where((r) => _isAssignedStatusRaw(r.rawStatus))
        .map(_mapRowToChildQuest)
        .toList();
  }

  Future<List<ChildQuest>> _fetchCompleted({required String childId}) async {
    final rows = await _selectRows(childId);
    return rows
        .where((r) => _isCompletedStatusRaw(r.rawStatus))
        .map(_mapRowToChildQuest)
        .toList();
  }

  Future<List<_ChildQuestRow>> _selectRows(String childId) async {
    try {
      final select =
          "id, child_id, quest_id, status, child_comment, photo_url, completed_at, "
          "quests(id, title, sphere, xp)";
      final rows = await _supabase
          .from('child_quests')
          .select(select)
          .eq('child_id', childId)
          .order('created_at', ascending: false);

      final list = (rows as List).cast<Map<String, dynamic>>();
      return list.map((r) => _ChildQuestRow.fromMap(r)).toList();
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB', 'Ошибка загрузки квестов: ${e.message}');
    } catch (e) {
      throw AuthException(
          'UNKNOWN', 'Ошибка загрузки квестов: ${e.toString()}');
    }
  }

  ChildQuest _mapRowToChildQuest(_ChildQuestRow row) {
    final quest = Quest(
      id: (row.questIdFromJoin ?? row.questId ?? row.id).toString(),
      title: row.title ?? '',
      type: _mapSphereToType(row.sphere ?? ''),
      createdBy: '',
      updatedAt: DateTime.now(),
    );

    final status = _mapStatus(row.rawStatus);

    return ChildQuest(
      id: row.id,
      childId: row.childId,
      quest: quest,
      status: status,
      childComment: row.childComment,
      photoUrl: row.photoUrl,
      completedAt: row.completedAt,
    );
  }

  bool _isAssignedStatusRaw(String s) {
    final v = s.toLowerCase();
    return {
      'assigned',
      'in_progress',
      'inprogress',
      'active',
      'ongoing',
    }.contains(v);
  }

  bool _isCompletedStatusRaw(String s) {
    final v = s.toLowerCase();
    return {
      'completed',
      'verified',
      'done',
      'finished',
      'approved',
      'complete',
    }.contains(v);
  }

  ChildQuestStatus _mapStatus(String s) {
    if (_isCompletedStatusRaw(s)) return ChildQuestStatus.completed;
    return ChildQuestStatus.assigned;
  }

  QuestType _mapSphereToType(String s) {
    switch (s.toLowerCase()) {
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
        if (s.startsWith('сил')) return QuestType.physical;
        if (s.startsWith('эмо')) return QuestType.emotional;
        if (s.startsWith('интел') || s.startsWith('cogn'))
          return QuestType.cognitive;
        if (s.startsWith('соц')) return QuestType.social;
        if (s.startsWith('смы') || s.startsWith('spirit'))
          return QuestType.spiritual;
        return QuestType.cognitive;
    }
  }

  final RegExp _uuidRe = RegExp(
    r'^[0-9a-fA-F]{8}\-?[0-9a-fA-F]{4}\-?[1-5][0-9a-fA-F]{3}\-?[89abAB][0-9a-fA-F]{3}\-?[0-9a-fA-F]{12}$',
  );
  bool _isUuid(String? s) => s != null && _uuidRe.hasMatch(s);
}

class _ChildQuestRow {
  final String id;
  final String childId;
  final String? questId;
  final String? questIdFromJoin;
  final String rawStatus;
  final String? childComment;
  final String? photoUrl;
  final DateTime? completedAt;
  final String? title;
  final String? sphere;

  _ChildQuestRow({
    required this.id,
    required this.childId,
    required this.rawStatus,
    this.questId,
    this.questIdFromJoin,
    this.childComment,
    this.photoUrl,
    this.completedAt,
    this.title,
    this.sphere,
  });

  factory _ChildQuestRow.fromMap(Map<String, dynamic> r) {
    final q = (r['quests'] as Map<String, dynamic>?) ?? const {};
    return _ChildQuestRow(
      id: r['id'].toString(),
      childId: r['child_id'].toString(),
      questId: r['quest_id']?.toString(),
      questIdFromJoin: q['id']?.toString(),
      rawStatus: (r['status']?.toString() ?? '').toLowerCase(),
      childComment: r['child_comment'] as String?,
      photoUrl: r['photo_url'] as String?,
      completedAt: r['completed_at'] != null
          ? DateTime.tryParse(r['completed_at'].toString())
          : null,
      title: (q['title'] as String?)?.trim(),
      sphere: (q['sphere'] as String?)?.trim(),
    );
  }
}
