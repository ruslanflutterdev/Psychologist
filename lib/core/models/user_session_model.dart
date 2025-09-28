class UserSessionModel {
  final String token;
  final String role;
  final String email;

  const UserSessionModel({
    required this.token,
    required this.role,
    required this.email,
  });
}
