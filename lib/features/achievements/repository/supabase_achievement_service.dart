import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/achievements/models/achievement_model.dart';
import 'package:heros_journey/features/achievements/repository/achievement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseAchievementService implements AchievementService {
  final sb.SupabaseClient _supabase;
  static const _tableName = 'achievements_catalog';

  sb.RealtimeChannel? _achievementsChannel;
  final StreamController<List<AchievementModel>> _controller =
      StreamController.broadcast();
  List<AchievementModel>? _latestCache;

  SupabaseAchievementService(this._supabase) {
    _subscribeToChanges();
  }

  AchievementModel _mapRow(Map<String, dynamic> r) {
    return AchievementModel(
      id: r['id'] as String,
      title: r['title'] as String,
      description: r['description'] as String,
      iconPath: r['icon_path'] as String,
      active: r['active'] as bool,
      createdBy: r['created_id'] as String,
      createdAt: DateTime.parse(r['created_at'].toString()),
      questId: r['quest_id'] as String?,
    );
  }

  Future<List<AchievementModel>> _fetchAchievements() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const [];

    const selectQuery =
        'id, title, description, icon_path, active, created_id, created_at, quest_id';

    try {
      final rows = await _supabase
          .from(_tableName)
          .select(selectQuery)
          .eq('created_id', userId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        debugPrint(
            'AchievementService: Full fetch completed for ${rows.length} achievements.');
      }

      return (rows as List).cast<Map<String, dynamic>>().map(_mapRow).toList();
    } on sb.PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('AchievementService PostgrestError on fetch: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'AchievementService Unknown Error on fetch: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<void> _refetchAndStream() async {
    try {
      final updatedList = await _fetchAchievements();
      _latestCache = updatedList;
      _controller.add(updatedList);
    } catch (e) {
      _controller.addError(e);
    }
  }

  Future<void> refresh() => _refetchAndStream();

  void _subscribeToChanges() async {
    await _refetchAndStream().catchError((Object e) {
      if (kDebugMode) {
        debugPrint('Initial Achievement fetch failed: ${e.toString()}');
      }
    });

    _achievementsChannel = _supabase
        .channel('public:achievements_channel')
        .onPostgresChanges(
          event: sb.PostgresChangeEvent.all,
          schema: 'public',
          table: _tableName,
          callback: (payload) async {
            if (kDebugMode) {
              debugPrint(
                  'Realtime achievement change detected: ${payload.eventType}');
            }
            await _refetchAndStream();
          },
        )
        .subscribe();
  }

  void dispose() {
    _achievementsChannel?.unsubscribe();
    _controller.close();
  }

  @override
  Stream<List<AchievementModel>> getMyAchievements() async* {
    if (_latestCache != null) {
      yield _latestCache!;
    } else {
      yield const [];
    }
    yield* _controller.stream;
  }

  @override
  Future<AchievementModel> createAchievement({
    required String title,
    required String description,
    required String iconName,
    required String userId,
  }) async {
    try {
      final row = await _supabase
          .from(_tableName)
          .insert({
            'title': title,
            'description': description,
            'icon_path': iconName,
            'created_id': userId,
          })
          .select()
          .single();

      final createdAch = _mapRow(row);

      await _refetchAndStream();

      return createdAch;
    } catch (e) {
      throw AuthException(
          'ACH_CREATE_ERROR', 'Ошибка создания ачивки: ${e.toString()}');
    }
  }

  @override
  Future<void> attachToQuest({
    required String achievementId,
    required String questId,
  }) async {
    try {
      final ach = await _supabase
          .from(_tableName)
          .select('quest_id')
          .eq('id', achievementId)
          .single();
      if (ach['quest_id'] != null) {
        throw AuthException(
          'ALREADY_ATTACHED',
          'Эта ачивка уже привязана к другому квесту.',
        );
      }

      await _supabase.from(_tableName).update({
        'quest_id': questId,
      }).eq('id', achievementId);

      await _refetchAndStream();
    } on AuthException {
      rethrow;
    } on sb.PostgrestException catch (e) {
      if (e.code == '23505') {
        throw AuthException(
          'QUEST_ALREADY_ATTACHED',
          'Этот квест уже привязан к другой ачивке.',
        );
      }
      throw AuthException('DB_ERROR', 'Ошибка привязки ачивки: ${e.message}');
    } catch (e) {
      throw AuthException(
        'UNKNOWN',
        'Неизвестная ошибка при привязке ачивки: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> detachFromQuest({required String achievementId}) async {
    try {
      await _supabase.from(_tableName).update({
        'quest_id': null,
      }).eq('id', achievementId);

      await _refetchAndStream();
    } on sb.PostgrestException catch (e) {
      throw AuthException('DB_ERROR', 'Ошибка отвязки ачивки: ${e.message}');
    } catch (e) {
      throw AuthException(
        'UNKNOWN',
        'Неизвестная ошибка при отвязке ачивки: ${e.toString()}',
      );
    }
  }
}
