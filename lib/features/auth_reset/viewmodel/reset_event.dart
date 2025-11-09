abstract class ResetEvent {}

class ResetEmailSubmitted extends ResetEvent {
  final String email;

  ResetEmailSubmitted({required this.email});
}

class ResetOtpSubmitted extends ResetEvent {
  final String otpCode;

  ResetOtpSubmitted({required this.otpCode});
}

class ResetPasswordSubmitted extends ResetEvent {
  final String password;
  final String confirm;

  ResetPasswordSubmitted({required this.password, required this.confirm});
}