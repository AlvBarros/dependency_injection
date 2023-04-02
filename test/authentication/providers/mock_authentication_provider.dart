import 'package:dependency_injection/authentication/providers/authentication_provider.dart';
import 'package:dependency_injection/model/user_session.dart';

class MockAuthenticationProvider implements AuthenticationProvider {
  static String successPassword = "123";

  UserSession? userSession;
  MockAuthenticationProvider({this.userSession});

  @override
  Future<UserSession?> signIn(String email, String password) {
    if (password == successPassword) {
      return Future.value(userSession);
    } else {
      return Future.value(null);
    }
  }
}
