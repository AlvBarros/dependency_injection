import 'user_session.dart';

class CognitoSession extends UserSession {
  final String accessToken;
  final String refreshToken;

  CognitoSession({
    required this.accessToken,
    required this.refreshToken,
    required super.username,
    required super.email,
  });

  @override
  String get sessionToken => accessToken;
}