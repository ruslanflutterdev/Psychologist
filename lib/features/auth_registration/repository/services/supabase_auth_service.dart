import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;
  SupabaseAuthService(this._client);

  @override
  Future<UserSessionModel> registerPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user == null) {
        throw const AuthException('Не удалось создать пользователя.');
      }

      final session = res.session ?? _client.auth.currentSession;
      final token = session?.accessToken ?? '';

      return UserSessionModel(
        token: token,
        role: 'psych',
        email: email.trim(),
      );
    } on AuthApiException catch (e) {
      throw AuthException(_mapSupabaseError(e));
    } catch (_) {
      throw const AuthException('Неизвестная ошибка при регистрации.');
    }
  }

  @override
  Future<UserSessionModel> loginPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.session == null) {
        throw const AuthException('Не удалось войти. Проверьте данные.');
      }

      return UserSessionModel(
        token: res.session!.accessToken,
        role: 'psych',
        email: email.trim(),
      );
    } on AuthApiException catch (e) {
      throw AuthException(_mapSupabaseError(e));
    } catch (_) {
      throw const AuthException('Неизвестная ошибка при входе.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'https://example.com/auth/callback',
      );
    } on AuthApiException catch (e) {
      throw AuthException(_mapSupabaseError(e));
    } catch (_) {
      throw const AuthException('Не удалось отправить письмо для сброса.');
    }
  }

  String _mapSupabaseError(AuthApiException e) {
    final msg = (e.message).toLowerCase();
    if (msg.contains('user already registered')) return 'Такой email уже зарегистрирован.';
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'Неверный логин или пароль.';
    }
    if (msg.contains('email not confirmed')) return 'Email не подтвержден. Проверьте почту.';
    if ((e.statusCode ?? 0) == 429) return 'Слишком много попыток. Попробуйте позже.';
    return e.message;
  }
}
