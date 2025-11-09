import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/auth_registration/repository/services/auth_service.dart';
import 'package:heros_journey/features/auth_registration/repository/services/supabase_auth_service.dart';
import 'package:heros_journey/features/auth_reset/model/reset_state.dart';
import 'package:heros_journey/features/auth_reset/viewmodel/reset_event.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  final AuthService auth;
  final SupabaseAuthService _supabaseAuthService;

  ResetBloc({required this.auth})
      : _supabaseAuthService = auth as SupabaseAuthService,
        super(ResetState.initial) {
    on<ResetEmailSubmitted>(_onEmailSubmitted);
    on<ResetOtpSubmitted>(_onOtpSubmitted);
    on<ResetPasswordSubmitted>(_onPasswordSubmitted);
  }

  Future<void> _onEmailSubmitted(
      ResetEmailSubmitted e, Emitter<ResetState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      email: e.email.trim(),
    ));

    try {
      await auth.requestPasswordReset(email: e.email.trim());
      emit(state.copyWith(
        isLoading: false,
        currentStep: ResetStep.enterOtp,
      ));
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

  Future<void> _onOtpSubmitted(
      ResetOtpSubmitted e, Emitter<ResetState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _supabaseAuthService.verifyOtpAndSetSession(
        email: state.email,
        token: e.otpCode.trim(),
      );

      emit(state.copyWith(
        isLoading: false,
        currentStep: ResetStep.enterNewPassword,
      ));
    } on AuthException catch (err) {
      emit(state.copyWith(isLoading: false, errorMessage: err.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Неверный код или неизвестная ошибка. Повторите попытку.',
        ),
      );
    }
  }

  Future<void> _onPasswordSubmitted(
      ResetPasswordSubmitted e, Emitter<ResetState> emit) async {
    if (e.password.trim().length < 6) {
      emit(state.copyWith(
          errorMessage: 'Минимум 6 символов', isLoading: false));
      return;
    }
    if (e.password.trim() != e.confirm.trim()) {
      emit(state.copyWith(
          errorMessage: 'Пароли не совпадают', isLoading: false));
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
          errorMessage: 'Неизвестная ошибка смены пароля. Повторите попытку.',
        ),
      );
    }
  }
}