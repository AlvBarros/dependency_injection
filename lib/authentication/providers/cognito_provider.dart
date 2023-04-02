import 'package:amazon_cognito_identity_dart_2/cognito.dart';

import '../../model/cognito_session.dart';
import 'authentication_provider.dart';

final _userPool = CognitoUserPool(
  "USER_POOL_ID",
  "CLIENT_ID",
  clientSecret: "CLIENT_SECRET",
);

class CognitoProvider implements AuthenticationProvider {
  const CognitoProvider();

  @override
  Future<CognitoSession?> signIn(String email, String password) async {
    try {
      final user = CognitoUser(email, _userPool, clientSecret: "CLIENT_SECRET");
      final details = AuthenticationDetails(
        username: email,
        password: password,
      );
      var session = await user.authenticateUser(
        details,
      );
      final usernameArg = (await user.getUserAttributes())!
          .firstWhere((element) => element.name == "username");
      final userSession = CognitoSession(
        accessToken: session?.accessToken.getJwtToken() ?? "",
        refreshToken: session?.refreshToken?.getToken() ?? "",
        username: usernameArg.value ?? "",
        email: email,
      );
      return userSession;
    } catch (e) {
      rethrow;
    }
  }
}
