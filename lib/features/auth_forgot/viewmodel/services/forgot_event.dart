abstract class ForgotEvent {}

class ForgotSubmitted extends ForgotEvent {
  final String email;
  final String newPassword;

  ForgotSubmitted({required this.email, required this.newPassword});
}

class ForgotBackPressed extends ForgotEvent {}
