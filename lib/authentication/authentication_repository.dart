import '../model/user_session.dart';
import 'providers/authentication_provider.dart';

class AuthenticationRepository {
  final AuthenticationProvider provider;
  AuthenticationRepository(this.provider);

  Future<UserSession?> signIn(String email, String password) {
    return provider.signIn(email, password).then((session) {
      if (session != null) {
        return session;
      }
      throw 'Failed to authenticate';
    }).catchError((error) {
      throw error;
    });
  }

  //...
}
