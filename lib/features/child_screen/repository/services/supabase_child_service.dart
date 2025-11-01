import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseChildService implements ChildService {
  final sb.SupabaseClient _supabase;
  sb.RealtimeChannel? _childrenChannel;
  sb.RealtimeChannel? _parentChannel;
  final StreamController<List<ChildModel>> _controller =
      StreamController.broadcast();
  List<ChildModel>? _latestChildrenCache;

  SupabaseChildService(this._supabase) {
    _subscribeToChildrenChanges();
  }

  ChildModel _mapRow(Map<String, dynamic> r) {
    ChildGender mapGender(String? gender) {
      if (gender == 'female') return ChildGender.female;
      return ChildGender.male;
    }

    List<dynamic>? normalizeJoinResult(dynamic joinResult) {
      if (joinResult == null) return null;
      if (joinResult is List) return joinResult.cast<dynamic>();
      if (joinResult is Map) return [joinResult];
      return null;
    }

    final parentChildsRaw = r['parent_childs'];
    final parentChilds = normalizeJoinResult(parentChildsRaw);
    final parentChild = parentChilds != null && parentChilds.isNotEmpty
        ? parentChilds.cast<Map<String, dynamic>>().first
        : null;
    final parentProfilesRaw = parentChild?['parent_profiles'];
    final normalizedParentProfiles = normalizeJoinResult(parentProfilesRaw);
    final parentProfile =
        normalizedParentProfiles != null && normalizedParentProfiles.isNotEmpty
            ? normalizedParentProfiles.cast<Map<String, dynamic>>().first
            : null;
    final parentFirstName = parentProfile?['first_name'] as String?;
    final parentLastName = parentProfile?['last_name'] as String?;
    final parentNumber = parentProfile?['number'] as String?;
    final parentFullName = (parentFirstName?.isNotEmpty == true &&
            parentLastName?.isNotEmpty == true)
        ? '$parentFirstName $parentLastName'
        : parentFirstName ?? parentLastName;

    return ChildModel(
      id: r['id'] as String,
      firstName: r['first_name'] as String,
      lastName: r['last_name'] as String,
      age: r['age'] as int,
      gender: mapGender(r['gender'] as String?),
      archetype: r['archetype'] as String?,
      updatedAt: DateTime.tryParse(r['updated_at'] as String),
      parentFullName: parentFullName,
      parentNumber: parentNumber,
    );
  }

  Future<List<ChildModel>> _fetchChildrenWithParents() async {
    const selectQuery = '''
      id, first_name, last_name, age, gender, archetype, updated_at,
      parent_childs(parent_profiles(first_name, last_name, number))
    ''';
    try {
      final rows = await _supabase
          .from('child_profiles')
          .select(selectQuery)
          .order('created_at', ascending: true);

      if (kDebugMode) {
        debugPrint(
            'SupabaseChildService: Full fetch completed for ${rows.length} children.');
      }

      final list =
          (rows as List).cast<Map<String, dynamic>>().map(_mapRow).toList();

      list.sort((a, b) {
        final dateA = a.updatedAt ?? DateTime(0);
        final dateB = b.updatedAt ?? DateTime(0);
        return dateA.compareTo(dateB);
      });

      return list;
    } on sb.PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'SupabaseChildService PostgrestError on fetch: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'SupabaseChildService Unknown Error on fetch: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<void> refetchAndStream() async {
    try {
      final updatedList = await _fetchChildrenWithParents();
      _latestChildrenCache = updatedList;
      _controller.add(updatedList);
    } catch (e) {
      _controller.addError(e);
    }
  }

  Future<void> refresh() => refetchAndStream();

  void _subscribeToChildrenChanges() async {
    await refetchAndStream().catchError((Object e) {
      if (kDebugMode) debugPrint('Initial data fetch failed: ${e.toString()}');
    });

    Future<void> refetchAndStreamHandler() async {
      await refetchAndStream();
    }

    _childrenChannel = _supabase
        .channel('public:child_profiles_events')
        .onPostgresChanges(
          event: sb.PostgresChangeEvent.all,
          schema: 'public',
          table: 'child_profiles',
          callback: (payload) async {
            if (kDebugMode) {
              debugPrint(
                  'Realtime child_profiles change detected: ${payload.eventType}');
            }
            await refetchAndStreamHandler();
          },
        )
        .subscribe();

    _parentChannel = _supabase
        .channel('public:parent_profiles_events')
        .onPostgresChanges(
          event: sb.PostgresChangeEvent.update,
          schema: 'public',
          table: 'parent_profiles',
          callback: (payload) async {
            if (kDebugMode) {
              debugPrint('Realtime parent_profiles UPDATE detected');
            }
            await refetchAndStreamHandler();
          },
        )
        .subscribe();
  }

  void dispose() {
    _childrenChannel?.unsubscribe();
    _parentChannel?.unsubscribe();
    _controller.close();
  }

  @override
  Stream<List<ChildModel>> getChildren() async* {
    if (_latestChildrenCache != null) {
      yield _latestChildrenCache!;
    } else {
      yield const [];
    }
    yield* _controller.stream;
  }
}
