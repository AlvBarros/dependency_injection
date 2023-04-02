class UserSession {
  final String username;
  final String email;

  UserSession({
    required this.username,
    required this.email,
  });

  String get sessionToken => "";
}