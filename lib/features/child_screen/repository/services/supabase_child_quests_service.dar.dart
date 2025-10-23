import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/child_screen/models/quest_filter_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_quests_service.dart';
import 'package:heros_journey/features/child_screen/repository/services/mock_child_quests_service.dart'; // Import for DuplicateQuestException
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseChildQuestsService implements ChildQuestsService {
  final sb.SupabaseClient _supabase;

  SupabaseChildQuestsService(this._supabase);


  // --- Реализация getAssigned/getCompleted (Временно заглушены) ---
  @override
  Stream<List<ChildQuest>> getAssigned(
    String childId, {
    QuestTimeFilter? filter,
  }) {
    return Stream.value(const []);
  }

  @override
  Stream<List<ChildQuest>> getCompleted(
    String childId, {
    QuestTimeFilter? filter,
  }) {
    return Stream.value(const []);
  }

  @override
  Future<void> assignQuest({
    required String childId,
    required Quest quest,
    required String assignedBy,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw AuthException('UNAUTHORIZED', 'Пользователь не авторизован.');
    }

    final data = {
      'child_id': childId,
      'quest_id': quest.id,
      'assigned_by': userId,
      'status': 'assigned',
    };

    try {
      await _supabase.from('child_quests').insert(data).select();
    } on sb.PostgrestException catch (e) {
      if (e.code == '23505') {
        throw DuplicateQuestException(
          'Квест "${quest.title}" уже назначен этому ребёнку.',
        );
      }
      if (e.message.contains('policy') || e.code == '42501') {
        throw AuthException(
          'PERMISSION_DENIED',
          'У вас нет прав назначать квесты этому ребёнку. Убедитесь, что вы его психолог.',
        );
      }
      throw Exception('Ошибка при назначении квеста: ${e.message}');
    } catch (e) {
      throw Exception(
        'Неизвестная ошибка при назначении квеста: ${e.toString()}',
      );
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
    throw UnimplementedError(
      'completeQuest not yet implemented in SupabaseChildQuestsService',
    );
  }
}
