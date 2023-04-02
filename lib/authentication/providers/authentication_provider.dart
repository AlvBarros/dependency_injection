import '../../model/user_session.dart';

abstract class AuthenticationProvider {
  Future<UserSession?> signIn(String email, String password) {
    throw UnimplementedError();
  }
}