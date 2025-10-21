import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';

enum RegistrationStatus { initial, submitting, success, error }

class RegistrationState {
  final RegistrationStatus status;
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final Role role;
  final String? errorMessage;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstName = '',
    this.lastName = '',
    this.role = Role.psychologist,
    this.errorMessage,
  });

  bool get isLoading => status == RegistrationStatus.submitting;
  bool get isSuccess => status == RegistrationStatus.success;

  RegistrationState copyWith({
    RegistrationStatus? status,
    String? email,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    Role? role,
    String? errorMessage,
  }) =>
      RegistrationState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        role: role ?? this.role,
        errorMessage: errorMessage,
      );
}
