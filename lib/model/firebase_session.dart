import 'user_session.dart';

class FirebaseSession extends UserSession {
  final String idToken;

  FirebaseSession({
    required this.idToken,
    required super.username,
    required super.email,
  });

  @override
  String get sessionToken => idToken;
}
