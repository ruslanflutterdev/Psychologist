abstract class ForgotEvent {}

class ForgotSubmitted extends ForgotEvent {
  final String email;

  ForgotSubmitted({required this.email});
}

class ForgotBackPressed extends ForgotEvent {}
