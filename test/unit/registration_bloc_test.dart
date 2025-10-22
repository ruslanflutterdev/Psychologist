import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_bloc.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';
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
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockSessionCubit = MockSessionCubit();
  });

  group('RegistrationBloc', () {
    const email = 'test@example.com';
    const password = 'password123';
    const userSession = UserSessionModel(
      token: 'token',
      role: 'psych',
      email: email,
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'изначальное состояние корректно',
      build: () => RegistrationBloc(
        auth: mockAuthService,
        sessionCubit: mockSessionCubit,
      ),
      expect: () => <dynamic>[],
      verify: (bloc) {
        expect(bloc.state, RegistrationState.initial);
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при успешной регистрации emit: isLoading -> isSuccess',
      build: () {
        when(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => userSession);
        when(() => mockSessionCubit.save(userSession)).thenReturn(null);
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      act: (bloc) =>
          bloc.add(RegistrationSubmitted(email: email, password: password)),
      expect: () => [
        isA<RegistrationState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RegistrationState>().having((s) => s.isSuccess, 'isSuccess', true),
      ],
      verify: (_) {
        verify(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).called(1);
        verify(() => mockSessionCubit.save(userSession)).called(1);
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при ошибке AuthException emit: isLoading -> errorMessage',
      build: () {
        when(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).thenThrow(AuthException('code', 'Test error message'));
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      act: (bloc) =>
          bloc.add(RegistrationSubmitted(email: email, password: password)),
      expect: () => [
        isA<RegistrationState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RegistrationState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Test error message',
        ),
      ],
      verify: (_) {
        verify(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNever(() => mockSessionCubit.save(any()));
      },
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'при неизвестной ошибке emit: isLoading -> generic error message',
      build: () {
        when(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).thenThrow(Exception('Unknown'));
        return RegistrationBloc(
          auth: mockAuthService,
          sessionCubit: mockSessionCubit,
        );
      },
      act: (bloc) =>
          bloc.add(RegistrationSubmitted(email: email, password: password)),
      expect: () => [
        isA<RegistrationState>().having((s) => s.isLoading, 'isLoading', true),
        isA<RegistrationState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Неизвестная ошибка. Повторите попытку.',
        ),
      ],
      verify: (_) {
        verify(
          () => mockAuthService.registerPsychologist(
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNever(() => mockSessionCubit.save(any()));
      },
    );
  });
}
