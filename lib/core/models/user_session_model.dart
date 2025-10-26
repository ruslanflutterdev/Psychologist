class UserSessionModel {
  final String token;
  final String role;
  final String email;
  final String firstName;
  final String lastName;

  const UserSessionModel({
    required this.token,
    required this.role,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
}
