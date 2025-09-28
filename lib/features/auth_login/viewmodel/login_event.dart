abstract class LoginEvent {}
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
}
class LoginGoRegister extends LoginEvent {}
class LoginForgotPassword extends LoginEvent {}

class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  const LoginState({this.isLoading = false, this.isSuccess = false, this.errorMessage});
  LoginState copyWith({bool? isLoading, bool? isSuccess, String? errorMessage}) =>
      LoginState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        errorMessage: errorMessage,
      );
  static const initial = LoginState();
}
