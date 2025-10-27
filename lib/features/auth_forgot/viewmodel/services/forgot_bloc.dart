import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/auth_forgot/model/forgot_state.dart';
import 'package:heros_journey/features/auth_forgot/viewmodel/services/forgot_event.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';

class ForgotBloc extends Bloc<ForgotEvent, ForgotState> {
  final AuthService auth;

  ForgotBloc({required this.auth}) : super(ForgotState.initial) {
    on<ForgotSubmitted>(_onSubmit);
    on<ForgotBackPressed>(_onBack);
  }

  Future<void> _onSubmit(ForgotSubmitted e, Emitter<ForgotState> emit) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      await auth.requestPasswordReset(email: e.email);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } on AuthException catch (err) {
      emit(state.copyWith(isLoading: false, errorMessage: err.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Неизвестная ошибка. Повторите попытку.',
        ),
      );
    }
  }

  void _onBack(ForgotBackPressed e, Emitter<ForgotState> emit) {}
}
