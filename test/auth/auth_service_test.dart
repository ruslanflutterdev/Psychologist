import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/errors/auth_exception.dart' as core;
import 'package:heros_journey/features/auth_registration/repository/services/supabase_auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  GoTrueClient get auth;
}

// --- ТЕСТЫ ---

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late SupabaseAuthService authService;

  setUp(() {
    mockAuth = MockGoTrueClient();
    mockSupabase = MockSupabaseClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    authService = SupabaseAuthService(mockSupabase);
  });

  group('AuthService Logout and Cleanup', () {
    test(
      'logout() calls GoTrueClient.signOut() and completes gracefully',
      () async {
        // Подготовка: Убеждаемся, что signOut() не бросает исключение
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        // Выполнение
        await authService.logout();

        // Проверка: Был ли вызван механизм выхода Supabase
        verify(() => mockAuth.signOut()).called(1);
      },
    );

    test(
      'clearAllLocalData() completes successfully (mock implementation is Future<void>.value())',
      () async {
        // Проверка: Ожидаем, что функция не бросит исключение
        expect(authService.clearAllLocalData(), completes);
      },
    );

    test('logout() handles signOut errors gracefully', () async {
      // Подготовка: Имитация ошибки сети при выходе
      when(() => mockAuth.signOut()).thenThrow(
        // ИСПРАВЛЕНО: Используем 2 позиционных аргумента кастомной ошибки
        core.AuthException('500', 'Network error during sign out'),
      );

      // Выполнение: Ожидаем, что функция не бросит исключение
      expect(authService.logout(), completes);

      // Проверка: Метод signOut все равно был вызван
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
