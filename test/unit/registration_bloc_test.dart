import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart'; // [!code addition]
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {}

class MockSessionCubit extends Mock implements SessionCubit {}

// Fakes
class UserSessionModelFake extends Fake implements UserSessionModel {}

void main() {
  late MockAuthService mockAuthService;
  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(UserSessionModelFake());
    // Регистрация fallback-значений для регистрации психолога с ФИО
    registerFallbackValue('test@example.com');
    registerFallbackValue('password123');
    registerFallbackValue('Test');
    registerFallbackValue('User');
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockSessionCubit = MockSessionCubit();
  });

  group('RegistrationBloc', () {
    const email = 'test@example.com';
    const password = 'password123';
    const firstName = 'Test'; // [!code addition]
    const lastName = 'User'; // [!code addition]
    const userSession = UserSessionModel(
      token: 'token',
      role: 'psychologist', // [!code change]
      email: email,
      firstName: firstName, // [!code addition]
      lastName: lastName, // [!code addition]
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'изначальное состояние корректно',
      build: () => RegistrationBloc(
        auth: mockAuthService,
        sessionCubit: mockSessionCubit,
      ),
      // [!code change] Проверяем, что состояние инициализировано правильно
      expect: () => <dynamic>[],
      verify: (bloc) {
        expect(bloc.state.status, RegistrationStatus.initial); // [!code change]
        expect(bloc.state.role, Role.psychologist); // [!code addition]
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при успешной регистрации emit: submitting -> success',
      build: () {
        when(
          // [!code change] Обновление сигнатуры с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).thenAnswer((_) async => userSession);
        when(() => mockSessionCubit.save(userSession)).thenReturn(null);
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      // [!code change] Передача ФИО в событие
      act: (bloc) => bloc.add(RegistrationSubmitted(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      )),
      expect: () => [
        // [!code change] Проверяем статус 'submitting'
        isA<RegistrationState>()
            .having((s) => s.status, 'status', RegistrationStatus.submitting),
        // [!code change] Проверяем статус 'success'
        isA<RegistrationState>()
            .having((s) => s.status, 'status', RegistrationStatus.success),
      ],
      verify: (_) {
        verify(
          // [!code change] Проверка вызова с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).called(1);
        verify(() => mockSessionCubit.save(userSession)).called(1);
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при ошибке AuthException emit: submitting -> error with message',
      build: () {
        when(
          // [!code change] Обновление сигнатуры с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).thenThrow(AuthException('code', 'Test error message'));
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      // [!code change] Передача ФИО в событие
      act: (bloc) => bloc.add(RegistrationSubmitted(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      )),
      expect: () => [
        // [!code change] Проверяем статус 'submitting'
        isA<RegistrationState>()
            .having((s) => s.status, 'status', RegistrationStatus.submitting),
        isA<RegistrationState>()
            .having((s) => s.status, 'status',
                RegistrationStatus.error) // [!code change]
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Test error message',
            ),
      ],
      verify: (_) {
        verify(
          // [!code change] Проверка вызова с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).called(1);
        verifyNever(() => mockSessionCubit.save(any()));
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при неизвестной ошибке emit: submitting -> generic error message',
      build: () {
        when(
          // [!code change] Обновление сигнатуры с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).thenThrow(Exception('Unknown'));
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      // [!code change] Передача ФИО в событие
      act: (bloc) => bloc.add(RegistrationSubmitted(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      )),
      expect: () => [
        // [!code change] Проверяем статус 'submitting'
        isA<RegistrationState>()
            .having((s) => s.status, 'status', RegistrationStatus.submitting),
        isA<RegistrationState>()
            .having((s) => s.status, 'status',
                RegistrationStatus.error) // [!code change]
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Неизвестная ошибка. Повторите попытку.',
            ),
      ],
      verify: (_) {
        verify(
          // [!code change] Проверка вызова с ФИО
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ).called(1);
        verifyNever(() => mockSessionCubit.save(any()));
      },
    );
  });
}
