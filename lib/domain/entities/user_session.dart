class UserSession {
  final int id;
  final String email;
  final String token;

  const UserSession({
    required this.id,
    required this.email,
    required this.token,
  });
}