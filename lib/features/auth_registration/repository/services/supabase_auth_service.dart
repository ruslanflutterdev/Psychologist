import 'package:flutter/foundation.dart';
import 'package:heros_journey/core/errors/auth_exception.dart' as core;
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseAuthService implements AuthService {
  final sb.SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  @override
  Future<UserSessionModel> registerPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      final redirectUrl = kIsWeb ? Uri.base.origin : null;

      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
      );

      final session = res.session ?? _supabase.auth.currentSession;
      if (session == null) {
        throw core.AuthException(
          'EMAIL_CONFIRM_REQUIRED',
          'Мы отправили ссылку на подтверждение. Подтвердите email, затем войдите.',
        );
      }

      return UserSessionModel(
        token: session.accessToken,
        role: 'psych',
        email: res.user?.email ?? email,
      );
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      throw core.AuthException(
        'UNKNOWN',
        'Ошибка регистрации: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserSessionModel> loginPsychologist({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = res.session ?? _supabase.auth.currentSession;
      if (session == null) {
        throw core.AuthException('NO_SESSION', 'Не удалось создать сессию.');
      }
      return UserSessionModel(
        token: session.accessToken,
        role: 'psych',
        email: res.user?.email ?? email,
      );
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      throw core.AuthException('UNKNOWN', 'Ошибка входа: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      final redirect = kIsWeb
          ? Uri.parse('${Uri.base.origin}/reset').toString()
          : null;

      await _supabase.auth.resetPasswordForEmail(email, redirectTo: redirect);
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      throw core.AuthException(
        'UNKNOWN',
        'Ошибка отправки письма: ${e.toString()}',
      );
    }
  }

  Future<void> _updatePasswordHandler(String newPassword) async {
    await _supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
  }

  Future<T?> _refresh<T>(Future<T> Function() handler) async {
    try {
      return await handler();
    } on sb.AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('auth session missing') || m.contains('invalid jwt')) {
        await _supabase.auth.refreshSession();
        return await handler();
      }
      rethrow;
    }
  }

  @override
  Future<void> applyNewPassword({required String newPassword}) async {
    try {
      await _refresh(() => _updatePasswordHandler(newPassword));
    } on sb.AuthException catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      print('Supabase AuthException status code: ${e.statusCode}');

      final message = _pretty(e.message);
      if (message == 'Срок действия ссылки для сброса пароля истёк. Пожалуйста, запросите сброс снова.') {
        throw core.AuthException('TOKEN_EXPIRED', message);
      }
      throw core.AuthException('SUPABASE', message);
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      if (e is core.AuthException) rethrow;

      throw core.AuthException(
        'UNKNOWN',
        'Неизвестная ошибка. Повторите попытку.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on sb.AuthException catch (e) {
      // Игнорируем ошибку выхода, чтобы не блокировать очистку локального состояния.
      if (kDebugMode) print('Supabase signOut failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) print('Supabase signOut failed: $e');
    }
  }

  String _pretty(String raw) {
    final m = raw.toLowerCase();
    if (m.contains('already registered') || m.contains('user already exists')) {
      return 'Email уже зарегистрирован';
    }
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'Неверный email или пароль';
    }
    if (m.contains('email not confirmed')) {
      return 'Подтвердите email через письмо и попробуйте снова';
    }
    if (m.contains('auth session missing') || m.contains('invalid refresh token')) {
      return 'Срок действия ссылки для сброса пароля истёк. Пожалуйста, запросите сброс снова.';
    }
    return raw;
  }
}
