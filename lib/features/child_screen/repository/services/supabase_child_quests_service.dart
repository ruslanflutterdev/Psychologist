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
    return Stream.fromFuture(_fetchQuests(
      childId: childId,
      statuses: const ['assigned', 'in_progress'],
      includeCompletedFields: false,
      orderBy: 'created_at',
      ascending: false,
    ));
  }

  @override
  Stream<List<ChildQuest>> getCompleted(
      String childId, {
        QuestTimeFilter? filter,
      }) {
    return Stream.fromFuture(_fetchQuests(
      childId: childId,
      statuses: const ['completed', 'verified'],
      includeCompletedFields: true,
      orderBy: 'completed_at',
      ascending: false,
    ));
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
          .select('id')
          .eq('child_id', childId)
          .eq('quest_id', quest.id)
          .inFilter('status', const ['assigned', 'in_progress'])
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
      throw AuthException('UNKNOWN', 'Ошибка назначения квеста: ${e.toString()}');
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
    try {
      if (!_isUuid(childId)) {
        throw AuthException('INVALID_ARG', 'childId не uuid: $childId');
      }
      if (!_isUuid(assignedId)) {
        throw AuthException('INVALID_ARG', 'assignedId не uuid: $assignedId');
      }

      final updated = await _supabase
          .from('child_quests')
          .update({
        'status': 'completed',
        'child_comment': comment,
        'photo_url': photoUrl,
        'completed_at': completedAt.toIso8601String(),
      })
          .eq('id', assignedId)
          .eq('child_id', childId)
          .select('id')
          .maybeSingle();

      if (updated == null) {
        throw AuthException('NOT_FOUND', 'Запись задания не найдена или нет доступа.');
      }
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB', 'Ошибка завершения квеста: ${e.message}');
    } catch (e) {
      throw AuthException('UNKNOWN', 'Ошибка завершения квеста: ${e.toString()}');
    }
  }

  Future<List<ChildQuest>> _fetchQuests({
    required String childId,
    required List<String> statuses,
    required bool includeCompletedFields,
    required String orderBy,
    required bool ascending,
  }) async {
    try {
      final select = includeCompletedFields
          ? "id, child_id, quest_id, status, child_comment, photo_url, completed_at, quests(id, title, sphere, xp)"
          : "id, child_id, quest_id, status, quests(id, title, sphere, xp)";

      final rows = await _supabase
          .from('child_quests')
          .select(select)
          .eq('child_id', childId)
          .inFilter('status', statuses)
          .order(orderBy, ascending: ascending);

      final list = (rows as List).cast<Map<String, dynamic>>();

      return list.map<ChildQuest>((row) {
        final q = (row['quests'] as Map<String, dynamic>? ?? const {});
        final sphere = (q['sphere'] as String? ?? '').toLowerCase().trim();

        final quest = Quest(
          // предпочитаем настоящий quests.id; если его нет — fallback на quest_id
          id: (q['id'] ?? row['quest_id'] ?? row['id']).toString(),
          title: (q['title'] as String? ?? '').trim(),
          type: _mapSphereToType(sphere),
          createdBy: '', // не используется в списке
          updatedAt: DateTime.now(),
        );

        final statusStr = (row['status'] as String? ?? '').toLowerCase();
        final status = _mapStatus(statusStr);

        DateTime? completedAt;
        if (includeCompletedFields && row['completed_at'] != null) {
          completedAt = DateTime.tryParse(row['completed_at'].toString());
        }

        return ChildQuest(
          id: row['id'].toString(),
          childId: row['child_id'].toString(),
          quest: quest,
          status: status,
          childComment:
          includeCompletedFields ? (row['child_comment'] as String?) : null,
          photoUrl: includeCompletedFields ? (row['photo_url'] as String?) : null,
          completedAt: completedAt,
        );
      }).toList();
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB', 'Ошибка загрузки квестов: ${e.message}');
    } catch (e) {
      throw AuthException('UNKNOWN', 'Ошибка загрузки квестов: ${e.toString()}');
    }
  }

  ChildQuestStatus _mapStatus(String s) {
    switch (s) {
      case 'assigned':
      case 'in_progress':
        return ChildQuestStatus.assigned;
      case 'completed':
      case 'verified':
        return ChildQuestStatus.completed;
      default:
        return ChildQuestStatus.assigned;
    }
  }

  QuestType _mapSphereToType(String s) {
    switch (s) {
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
        if (s.startsWith('интел') || s.startsWith('cogn')) return QuestType.cognitive;
        if (s.startsWith('соц')) return QuestType.social;
        if (s.startsWith('смы') || s.startsWith('spirit')) return QuestType.spiritual;
        return QuestType.cognitive;
    }
  }

  final RegExp _uuidRe = RegExp(
    r'^[0-9a-fA-F]{8}\-?[0-9a-fA-F]{4}\-?[1-5][0-9a-fA-F]{3}\-?[89abAB][0-9a-fA-F]{3}\-?[0-9a-fA-F]{12}$',
  );
  bool _isUuid(String? s) => s != null && _uuidRe.hasMatch(s);
}
