abstract class RegistrationEvent {}

class RegistrationSubmitted extends RegistrationEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}

class RegistrationBackPressed extends RegistrationEvent {}
