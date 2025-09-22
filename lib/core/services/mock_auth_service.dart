import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/user_session.dart';
import 'package:heros_journey/core/services/auth_service.dart';

class MockAuthService implements AuthService {
  final Set<String> _registeredEmails = {'busy@school.kz'};
  final Map<String, String> _passwords = {'busy@school.kz': '123456'};
  Duration latency = const Duration(milliseconds: 600);
  bool failNetwork = false;

  @override
  Future<UserSession> registerPsychologist({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw AuthException('NETWORK', 'Сеть недоступна. Повторите позже.');
    }

    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw AuthException('INVALID_EMAIL', 'Введите корректный E‑mail.');
    }
    if (password.trim().length < 6) {
      throw AuthException(
        'WEAK_PASSWORD',
        'Пароль должен быть не короче 6 символов.',
      );
    }
    if (_registeredEmails.contains(normalized)) {
      throw AuthException('EMAIL_TAKEN', 'Адрес уже занят. Попробуйте другой.');
    }

    _registeredEmails.add(normalized);
    _passwords[normalized] = password.trim();
    return UserSession(
      token:
          'mock-token:${normalized.hashCode}:${DateTime.now().millisecondsSinceEpoch}',
      role: 'psych',
      email: normalized,
    );
  }

  @override
  Future<UserSession> loginPsychologist({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw AuthException('NETWORK', 'Сеть недоступна. Повторите позже.');
    }
    final normalized = email.trim().toLowerCase();
    final pass = password.trim();
    if (!_registeredEmails.contains(normalized) ||
        _passwords[normalized] != pass) {
      throw AuthException('INVALID_CREDENTIALS', 'Неверный логин или пароль');
    }
    return UserSession(
      token:
          'mock-token:${normalized.hashCode}:${DateTime.now().millisecondsSinceEpoch}',
      role: 'psych',
      email: normalized,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await Future<void>.delayed(latency);
    if (failNetwork) {
      throw AuthException('NETWORK', 'Сеть недоступна. Повторите позже.');
    }

    final normalized = email.trim().toLowerCase();
    if (!_registeredEmails.contains(normalized)) {
      throw AuthException('EMAIL_NOT_FOUND', 'Email не найден');
    }
    if (newPassword.trim().length < 6) {
      throw AuthException(
        'WEAK_PASSWORD',
        'Пароль должен быть не короче 6 символов.',
      );
    }

    _passwords[normalized] = newPassword.trim();
  }
}
