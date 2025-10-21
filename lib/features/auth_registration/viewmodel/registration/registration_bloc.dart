import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/registration/registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthService auth;
  final SessionCubit sessionCubit;

  RegistrationBloc({required this.auth, required this.sessionCubit})
    : super(const RegistrationState()) {
    on<RegistrationSubmitted>(_onSubmit);
    on<RegistrationBackPressed>(_onBack);
  }

  Future<void> _onSubmit(
    RegistrationSubmitted e,
    Emitter<RegistrationState> emit,
  ) async {
    emit(
      state.copyWith(status: RegistrationStatus.submitting),
    );
    try {
      final UserSessionModel session = await auth.registerPsychologist(
        email: e.email,
        password: e.password,
        firstName: e.firstName,
        lastName: e.lastName,
      );
      sessionCubit.save(session);
      emit(state.copyWith(status: RegistrationStatus.success));
    } on AuthException catch (err) {
      emit(
        state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: err.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: 'Неизвестная ошибка. Повторите попытку.',
        ),
      );
    }
  }

  void _onBack(RegistrationBackPressed e, Emitter<RegistrationState> emit) {}
}
