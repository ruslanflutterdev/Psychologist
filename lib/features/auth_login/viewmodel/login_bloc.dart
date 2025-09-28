import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/user_session_model.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/auth_login/viewmodel/login_event.dart';
import 'package:heros_journey/features/auth_registration/viewmodel/services/auth_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService auth;
  final SessionCubit sessionCubit;

  LoginBloc({required this.auth, required this.sessionCubit}) : super(LoginState.initial) {
    on<LoginSubmitted>(_onSubmit);
    on<LoginGoRegister>((event, emit) {/* handled in View */});
    on<LoginForgotPassword>((event, emit) {/* handled in View */});
  }

  Future<void> _onSubmit(LoginSubmitted e, Emitter<LoginState> emit) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final UserSessionModel session = await auth.loginPsychologist(email: e.email, password: e.password);
      if (session.role != 'psych') {
        throw AuthException('INVALID_CREDENTIALS', 'Неверный логин или пароль');
      }
      sessionCubit.save(session);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on AuthException catch (err) {
      emit(state.copyWith(isLoading: false, isSuccess: false, errorMessage: err.message));
    } catch (_) {
      emit(state.copyWith(isLoading: false, isSuccess: false, errorMessage: 'Неизвестная ошибка. Повторите попытку.'));
    }
  }
}
