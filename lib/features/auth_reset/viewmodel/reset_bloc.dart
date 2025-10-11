import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_reset/model/reset_state.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_event.dart';


class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final AuthService auth;

  ResetBloc({required this.auth}) : super(ResetState.initial) {
    on<ResetSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(ResetSubmitted e, Emitter<ResetState> emit) async {
    if (e.password.trim().length < 6) {
      emit(state.copyWith(errorMessage: 'Минимум 6 символов'));
      return;
    }
    if (e.password.trim() != e.confirm.trim()) {
      emit(state.copyWith(errorMessage: 'Пароли не совпадают'));
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      await auth.applyNewPassword(newPassword: e.password.trim());
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
}
