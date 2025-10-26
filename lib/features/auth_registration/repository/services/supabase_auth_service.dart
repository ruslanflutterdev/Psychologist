import 'package:flutter/foundation.dart';
import 'package:heros_journey/core/errors/auth_exception.dart' as core;
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseAuthService implements AuthService {
  final sb.SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  /// Регистрация психолога.
  /// Создаём пользователя, проставляем роль в `app_users`,
  /// создаём/обновляем профиль в `psych_profiles` и возвращаем текущую сессию.
  @override
  Future<UserSessionModel> registerPsychologist({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final redirectUrl = kIsWeb ? Uri.base.origin : null;

      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      final session = res.session ?? _supabase.auth.currentSession;
      final user = res.user ?? _supabase.auth.currentUser;

      if (user == null) {
        throw core.AuthException('NO_USER', 'Пользователь не создан.');
      }

      const role = 'psych';

      // Фиксируем роль пользователя
      await _supabase.from('app_users').upsert(
        {
          'user_id': user.id,
          'role': role,
        },
        onConflict: 'user_id',
      );

      await _supabase.from('psych_profiles').upsert(
        {
          'id': user.id,
          'user_id': user.id,
          'first_name': firstName,
          'last_name': lastName,
        },
        onConflict: 'user_id',
      );

      // При включённом подтверждении email сессии может не быть прямо сейчас.
      // Вернём что есть — токен может быть пустым до подтверждения.
      final token = session?.accessToken ?? '';
      return UserSessionModel(
        token: token,
        role: role,
        email: email,
        firstName: firstName,
        lastName: lastName,
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

  /// Вход психолога по email+password.
  /// Загружаем роль из `app_users` и профиль из `psych_profiles` (с фоллбэком на metadata).
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
      final user = res.user ?? _supabase.auth.currentUser;

      if (session == null || user == null) {
        throw core.AuthException(
          'NO_SESSION',
          'Не удалось получить сессию или пользователя.',
        );
      }

      // Роль берём из app_users
      final currentRole = await _loadRole(user.id);

      // Профиль берём из psych_profiles, при отсутствии — из user.userMetadata
      final profileData = await _loadProfileData(user.id);
      return UserSessionModel(
        token: session.accessToken,
        role: currentRole,
        email: user.email ?? email,
        firstName: profileData['first_name'] as String? ?? '',
        lastName: profileData['last_name'] as String? ?? '',
      );
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      if (e is core.AuthException) rethrow;
      throw core.AuthException('UNKNOWN', 'Ошибка входа: ${e.toString()}');
    }
  }

  /// Отправка письма для сброса пароля
  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      final redirectUrl = kIsWeb ? Uri.base.resolve('/reset').toString() : null;
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      throw core.AuthException(
        'UNKNOWN',
        'Ошибка отправки письма: ${e.toString()}',
      );
    }
  }

  /// Применяет новый пароль непосредственно в "recovery"-сессии.
  /// Соответствует методу интерфейса AuthService.applyNewPassword.
  @override
  Future<void> applyNewPassword({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
    } on sb.AuthException catch (e) {
      throw core.AuthException('SUPABASE', _pretty(e.message));
    } catch (e) {
      throw core.AuthException(
        'UNKNOWN',
        'Ошибка смены пароля: ${e.toString()}',
      );
    }
  }

  /// Выход
  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on sb.AuthException catch (e) {
      if (kDebugMode)
        debugPrint('SUPABASE logout error: ${_pretty(e.message)}');
    } on core.AuthException catch (e) {
      if (kDebugMode) debugPrint('CORE AuthException on logout: ${e.message}');
    } catch (e) {
      if (kDebugMode) debugPrint('UNKNOWN logout error: ${e.toString()}');
    }
  }

  /// Очистка локальных данных (если что-то кэшируете в приложении)
  @override
  Future<void> clearAllLocalData() async {
    return;
  }

  /// Загрузка профиля: сначала из `psych_profiles`, если записи нет — из metadata.
  Future<Map<String, dynamic>> _loadProfileData(String userId) async {
    final resp = await _supabase
        .from('psych_profiles')
        .select('first_name, last_name')
        .eq('user_id', userId)
        .maybeSingle();

    String? firstName;
    String? lastName;

    if (resp != null) {
      firstName = (resp['first_name'] as String?)?.trim();
      lastName = (resp['last_name'] as String?)?.trim();
    }
    final u = _supabase.auth.currentUser;
    final meta = u?.userMetadata ?? const <String, dynamic>{};
    firstName = (firstName ?? meta['first_name'] as String? ?? '').trim();
    lastName = (lastName ?? meta['last_name'] as String? ?? '').trim();

    return {'first_name': firstName, 'last_name': lastName};
  }

  Future<String> _loadRole(String userId) async {
    try {
      final roleResponse = await _supabase
          .from('app_users')
          .select('role')
          .eq('user_id', userId)
          .single();
      final Map<String, dynamic> data = roleResponse;
      return data['role'].toString();
    } on sb.PostgrestException catch (e) {
      if (e.code == 'PGRST116') return 'psych';
      rethrow;
    }
  }

  String _pretty(String raw) {
    final m = raw.toLowerCase();
    if (m.contains('email already registered') ||
        m.contains('user already registered') ||
        m.contains('already exists')) {
      return 'Email уже зарегистрирован';
    }
    if (m.contains('invalid login') || m.contains('invalid credentials')) {
      return 'Неверный email или пароль';
    }
    if (m.contains('email not confirmed')) {
      return 'Подтвердите email через письмо и попробуйте снова';
    }
    if (m.contains('auth session missing') ||
        m.contains('invalid refresh token')) {
      return 'Срок действия ссылки для сброса пароля истёк. Пожалуйста, запросите сброс снова.';
    }
    return raw;
  }
}
