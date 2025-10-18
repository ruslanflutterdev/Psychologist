import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/router/app_router.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/repository/services/psychologist_service.dart';
import 'package:heros_journey/features/psychologist_screen/view/screens/psychologist_screen.dart';
import 'package:mocktail/mocktail.dart';

// --- MOCKS ---

// Мок-класс для AuthService, необходим для проверки вызова logout и clearAllLocalData
class MockAuthService extends Mock implements AuthService {
  Future<void> clearAllLocalData() =>
      super.noSuchMethod(Invocation.method(#clearAllLocalData, []));
}

// Мок-класс для SessionCubit
class MockSessionCubit extends Mock implements SessionCubit {}

// Мок-класс для PsychologistService, необходим для успешной загрузки PsychologistBody
class MockPsychologistService extends Mock implements PsychologistService {}

// Мок-класс для ChildService, необходим для успешной загрузки PsychologistBody
class MockChildService extends Mock implements ChildService {}

// --- ТЕСТЫ ---

void main() {
  late MockAuthService mockAuthService;
  late MockSessionCubit mockSessionCubit;
  late MockPsychologistService mockPsychologistService;
  late MockChildService mockChildService;

  // Регистрация fallback-значений для mocktail
  setUpAll(() {
    registerFallbackValue(
      const UserSessionModel(token: 'token', role: 'psych', email: 'a@b.c'),
    );
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockSessionCubit = MockSessionCubit();
    mockPsychologistService = MockPsychologistService();
    mockChildService = MockChildService();

    // --- ИСПРАВЛЕНО: Добавлено мокирование stream и close() для совместимости с BlocProvider ---
    when(
      () => mockSessionCubit.stream,
    ).thenAnswer((_) => Stream<UserSessionModel?>.empty());
    when(() => mockSessionCubit.close()).thenAnswer((_) => Future.value());

    // --- НАСТРОЙКА MOCK-СЕРВИСОВ ---
    // Для успешной загрузки PsychologistScreen и Body:
    when(() => mockPsychologistService.getProfile()).thenAnswer(
      (_) => Future.value(
        const PsychologistModel(firstName: 'Test', lastName: 'User'),
      ),
    );
    when(
      () => mockChildService.getChildren(),
    ).thenAnswer((_) => Future.value(<ChildModel>[]));

    // Переопределение ServiceRegistry для использования моков
    ServiceRegistry.auth = mockAuthService;
    ServiceRegistry.psychologist = mockPsychologistService;
    ServiceRegistry.child = mockChildService;

    // --- НАСТРОЙКА MOCK-МЕТОДОВ ВЫХОДА ---
    // Сессия считается активной перед тестом
    when(() => mockSessionCubit.isAuthorized).thenReturn(true);
    when(() => mockSessionCubit.state).thenReturn(
      const UserSessionModel(
        token: 'active',
        role: 'psych',
        email: 'test@psych.com',
      ),
    );
    when(() => mockSessionCubit.clear()).thenAnswer((_) {});

    // Мокирование методов AuthService (logout и clearAllLocalData)
    when(() => mockAuthService.logout()).thenAnswer((_) => Future.value());
    when(
      () => mockAuthService.clearAllLocalData(),
    ).thenAnswer((_) => Future.value());
  });

  // Вспомогательный метод для создания тестируемого виджета
  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [BlocProvider<SessionCubit>(create: (_) => mockSessionCubit)],
      child: MaterialApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const PsychologistScreen(),
        routes: {
          // Имитация страницы логина для проверки редиректа
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
  }

  group('PsychologistScreen Logout Flow', () {
    testWidgets(
      'Tapping "Выйти" button performs full logout sequence and redirects',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester
            .pumpAndSettle(); // Ждем завершения загрузки PsychologistBody

        // 1. Проверяем, что экран загружен и кнопка "Выйти" присутствует
        expect(find.byType(PsychologistScreen), findsOneWidget);
        final logoutButton = find.text('Выйти');
        expect(logoutButton, findsOneWidget);

        // 2. Нажимаем кнопку
        await tester.tap(logoutButton);
        await tester
            .pumpAndSettle(); // Ждем завершения асинхронной операции и навигации

        // 3. Проверки последовательности выхода (согласно критериям):

        // Проверка 3.1: Был вызван Supabase logout
        verify(() => mockAuthService.logout()).called(1);

        // Проверка 3.2: Была вызвана глубокая очистка данных (localStorage, IndexedDB и т.д.)
        verify(() => mockAuthService.clearAllLocalData()).called(1);

        // Проверка 3.3: Был вызван сброс локального стейта (SessionCubit)
        verify(() => mockSessionCubit.clear()).called(1);

        // Проверка 3.4: Произошел редирект на экран логина
        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.byType(PsychologistScreen), findsNothing);
      },
    );

    testWidgets(
      'PopScope invokation performs full logout sequence and redirects',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // 1. Имитируем попытку возврата (PopScope перехватывает "назад")
        tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // 2. Проверки последовательности выхода:

        // Проверка 2.1: Был вызван Supabase logout
        verify(() => mockAuthService.logout()).called(1);

        // Проверка 2.2: Была вызвана глубокая очистка данных
        verify(() => mockAuthService.clearAllLocalData()).called(1);

        // Проверка 2.3: Был вызван сброс локального стейта (SessionCubit)
        verify(() => mockSessionCubit.clear()).called(1);

        // Проверка 2.4: Произошел редирект на экран логина
        expect(find.text('Login Screen'), findsOneWidget);
      },
    );
  });
}
