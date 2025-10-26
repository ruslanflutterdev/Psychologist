import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/repository/services/psychologist_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class SupabasePsychologistService implements PsychologistService {
  final SupabaseClient _supabase;

  SupabasePsychologistService(this._supabase);

  @override
  Future<PsychologistModel> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('UNAUTHORIZED', 'Пользователь не авторизован.');
    }

    try {
      Map<String, dynamic>? row;
      try {
        final byUserId = await _supabase
            .from('psych_profiles')
            .select('first_name, last_name, avatar_url, user_id, id')
            .eq('user_id', user.id)
            .maybeSingle();
        row = byUserId;
      } on PostgrestException {
        // игнорируем — попробуем по id
      }

      if (row == null) {
        try {
          final byId = await _supabase
              .from('psych_profiles')
              .select('first_name, last_name, avatar_url, user_id, id')
              .eq('id', user.id)
              .maybeSingle();
          row = byId;
        } on PostgrestException {
          // игнорируем — пойдём в userMetadata
        }
      }

      String? firstName;
      String? lastName;
      String? avatarUrl;

      if (row != null) {
        firstName = (row['first_name'] as String?)?.trim();
        lastName = (row['last_name'] as String?)?.trim();
        avatarUrl = row['avatar_url'] as String?;
      }

      final meta = user.userMetadata ?? const <String, dynamic>{};
      firstName = (firstName ?? meta['first_name'] as String? ?? '').trim();
      lastName = (lastName ?? meta['last_name'] as String? ?? '').trim();

      return PsychologistModel(
        id: user.id,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      throw AuthException(
        'PROFILE_FETCH_FAILED',
        'Не удалось загрузить профиль психолога: ${e.toString()}',
      );
    }
  }
}
