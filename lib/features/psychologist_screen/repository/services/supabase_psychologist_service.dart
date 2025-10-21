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
      final response = await _supabase
          .from('psych_profiles')
          .select('first_name, last_name, avatar_url')
          .eq('id', user.id)
          .single();

      final Map<String, dynamic> data = response;

      return PsychologistModel(
        id: user.id,
        firstName: data['first_name'] as String,
        lastName: data['last_name'] as String,
        avatarUrl: data['avatar_url'] as String?,
      );
    } catch (e) {
      throw AuthException(
        'PROFILE_FETCH_FAILED',
        'Не удалось загрузить профиль психолога: ${e.toString()}',
      );
    }
  }
}
