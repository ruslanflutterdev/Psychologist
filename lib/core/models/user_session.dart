class UserSession {
  final String token;
  final String role;
  final String email;
  const UserSession({
    required this.token,
    required this.role,
    required this.email,
  });
}
