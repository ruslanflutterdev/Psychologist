import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/services/agreement_service.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/agreement/view/agreement_screen.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/view/screens/registration_screen.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/consent_checkbox.dart';
import 'package:heros_journey/features/auth_registration/view/widgets/registration_submit_button.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}

class MockAgreementService extends Mock implements AgreementService {}

class MockSessionCubit extends Mock implements SessionCubit {}

// Fakes
class UserSessionModelFake extends Fake implements UserSessionModel {}

void main() {
  late MockAuthService mockAuth;
  late MockAgreementService mockAgreement;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(UserSessionModelFake());
  });

  setUp(() {
    mockAuth = MockAuthService();
    mockAgreement = MockAgreementService();
    mockSessionCubit = MockSessionCubit();
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream<UserSessionModel?>.empty());
    when(() => mockSessionCubit.close()).thenAnswer((_) => Future.value());
    // Инициализируем ServiceRegistry с мок-сервисами
    ServiceRegistry.auth = mockAuth;
    ServiceRegistry.agreement = mockAgreement;
  });

  testWidgets(
    'Кнопка "Зарегистрироваться" неактивна, пока не отмечено согласие, и активна после отметки',
        (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RegistrationBloc>(
              create: (context) => RegistrationBloc(
                auth: mockAuth,
                sessionCubit: mockSessionCubit,
              ),
            ),
            BlocProvider<SessionCubit>(
              create: (context) => mockSessionCubit,
            ),
          ],
          child: MaterialApp(
            // ИСПРАВЛЕНО: Убран SingleChildScrollView
            home: const RegistrationScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/psychologist_screen') {
                return MaterialPageRoute(builder: (_) => const Text('Psychologist Screen'));
              }
              return null;
            },
          ),
        ),
      );

      // Находим кнопку и проверяем, что она неактивна
      final submitButton = find.byType(RegistrationSubmitButton);
      expect(submitButton, findsOneWidget);
      expect(tester.widget<RegistrationSubmitButton>(submitButton).enabled, isFalse);

      // Находим чекбокс и нажимаем на него (используем более точный finder)
      final consentCheckbox = find.byType(ConsentCheckbox);
      await tester.tap(consentCheckbox);
      await tester.pump();

      const validEmail = 'test@example.com';
      const validPassword = 'CorrectPassword1!';

      // Проверяем, что кнопка стала активной
      expect(tester.widget<RegistrationSubmitButton>(submitButton).enabled, isTrue);

      // Заполняем поля
      await tester.enterText(find.byType(TextFormField).at(0), validEmail); // Email
      await tester.enterText(find.byType(TextFormField).at(1), validPassword); // Пароль
      await tester.enterText(find.byType(TextFormField).at(2), validPassword); // Подтверждение
      await tester.pump();

      // Кнопка остается активной
      expect(tester.widget<RegistrationSubmitButton>(submitButton).enabled, isTrue);

      // Нажимаем на кнопку и проверяем, что метод регистрации вызывается
      when(() => mockAuth.registerPsychologist(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => const UserSessionModel(token: 'token', role: 'psych', email: validEmail));

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(() => mockAuth.registerPsychologist(email: validEmail, password: validPassword)).called(1);
    },
  );

  testWidgets(
    'При нажатии на ссылку открывается пользовательское соглашение',
        (tester) async {
      when(() => mockAgreement.getUserAgreementText()).thenAnswer((_) async => 'Test Agreement Text');

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RegistrationBloc>(
              create: (context) => RegistrationBloc(
                auth: mockAuth,
                sessionCubit: mockSessionCubit,
              ),
            ),
            BlocProvider<SessionCubit>(
              create: (context) => mockSessionCubit,
            ),
          ],
          child: MaterialApp(
            home: const RegistrationScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/agreement') {
                return MaterialPageRoute(
                  builder: (_) => const AgreementScreen(),
                );
              }
              return null;
            },
          ),
        ),
      );

      // Находим ссылку и нажимаем на неё
      final agreementLink = find.text('пользовательским соглашением');
      expect(agreementLink, findsOneWidget);
      await tester.tap(agreementLink);
      await tester.pumpAndSettle();

      // Проверяем, что открылся экран с соглашением и отображается текст
      expect(find.byType(AgreementScreen), findsOneWidget);
      expect(find.text('Пользовательское соглашение'), findsOneWidget);
      expect(find.text('Test Agreement Text'), findsOneWidget);
    },
  );
}
