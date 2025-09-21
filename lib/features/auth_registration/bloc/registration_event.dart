abstract class RegistrationEvent {}

class RegistrationSubmitted extends RegistrationEvent {
  final String email;
  final String password;
  RegistrationSubmitted({required this.email, required this.password});
}

class RegistrationBackPressed extends RegistrationEvent {}
