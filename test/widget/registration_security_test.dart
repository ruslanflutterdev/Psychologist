import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/view/screens/registration_screen.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/consent_checkbox.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_submit_button.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---
class MockAuthService extends Mock implements AuthService {}

class MockSessionCubit extends Mock implements SessionCubit {}

// Fakes
class UserSessionModelFake extends Fake implements UserSessionModel {}

// Utility function to find the password fields
Finder findPasswordField(String labelText) =>
    find.widgetWithText(TextFormField, labelText);

void main() {
  late MockAuthService mockAuth;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(UserSessionModelFake());
  });

  setUp(() {
    mockAuth = MockAuthService();
    mockSessionCubit = MockSessionCubit();
    // Настройка заглушек для BlocProvider
    when(
      () => mockSessionCubit.stream,
    ).thenAnswer((_) => const Stream<UserSessionModel?>.empty());
    when(() => mockSessionCubit.close()).thenAnswer((_) => Future.value());
    when(
      () => mockAuth.registerPsychologist(
        email: any(named: 'email'),
        password: any(named: 'password'),
        firstName: '',
        lastName: '',
      ),
    ).thenAnswer(
      (_) async => const UserSessionModel(
          token: 't', role: 'p', email: 'e', firstName: '', lastName: ''),
    );

    // Для виджет-теста устанавливаем mockAuth в ServiceRegistry
    ServiceRegistry.auth = mockAuth;
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegistrationBloc>(
          create: (context) =>
              RegistrationBloc(auth: mockAuth, sessionCubit: mockSessionCubit),
        ),
        BlocProvider<SessionCubit>(create: (context) => mockSessionCubit),
      ],
      child: MaterialApp(
        home: const RegistrationScreen(),
        routes: {
          '/agreement': (context) =>
              const Scaffold(body: Text('Agreement Screen')),
          '/psychologist_screen': (context) =>
              const Scaffold(body: Text('Psych Screen')),
        },
      ),
    );
  }

  group('Registration Password Security Tests', () {
    testWidgets('Validation errors are shown for weak passwords in both fields',
        (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = findPasswordField('Пароль');
      final confirmField = findPasswordField('Подтверждение пароля');
      final submitButton = find.byType(RegistrationSubmitButton);
      final consentCheckbox = find.byType(ConsentCheckbox);

      // 1. Отмечаем согласие, чтобы кнопка стала активной
      await tester.tap(consentCheckbox);
      await tester.pump();

      // Кнопка активна, так как проверяется только _canSubmit (согласие + не loading)
      expect(
        tester.widget<RegistrationSubmitButton>(submitButton).enabled,
        isTrue,
      );

      // 2. Вводим слабый пароль (Short: 7 символов)
      await tester.enterText(passwordField, '1234567');
      await tester.enterText(confirmField, '1234567');

      // Активируем валидацию, нажимая на кнопку submit. Это вызовет validate(), который вернет false.
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем, что отображаются ошибки (Минимум 8 символов)
      expect(
        find.text('Минимум 8 символов'),
        findsNWidgets(2),
        reason: 'Ошибка длины должна быть для обоих полей',
      );

      // 3. Вводим пароль, который НЕ содержит заглавную букву (длина > 8)
      await tester.enterText(passwordField, 'weakpass123!');
      await tester.enterText(confirmField, 'weakpass123!');

      // Активируем валидацию, нажимая на кнопку submit
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем ошибку для обоих полей
      expect(
        find.text('Добавьте заглавную букву'),
        findsNWidgets(2),
        reason: 'Ошибка заглавной буквы должна быть для обоих полей',
      );

      // 4. Вводим сильный, но несовпадающий пароль
      await tester.enterText(passwordField, 'Correct1!');
      await tester.enterText(confirmField, 'Correct2!');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем, что ошибки безопасности исчезли, но осталась ошибка несовпадения
      expect(find.text('Добавьте заглавную букву'), findsNothing);
      expect(
        find.text('Пароли не совпадают'),
        findsOneWidget,
        reason: 'Ошибка несовпадения должна быть показана',
      );

      // 5. Вводим полностью валидный и совпадающий пароль
      await tester.enterText(confirmField, 'Correct1!');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем, что ошибок нет, и кнопка активна
      expect(find.text('Пароли не совпадают'), findsNothing);
      expect(
        tester.widget<RegistrationSubmitButton>(submitButton).enabled,
        isTrue,
        reason: 'Кнопка должна быть активна',
      );

      // 6. Проверяем, что при попытке регистрации с корректным паролем вызывается auth.register
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      ); // Вводим Email
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(
        () => mockAuth.registerPsychologist(
          email: 'test@example.com',
          password: 'Correct1!',
          firstName: '',
          lastName: '',
        ),
      ).called(1);
    });
  });
}
