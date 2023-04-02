import 'package:dependency_injection/authentication/authentication_repository.dart';
import 'package:dependency_injection/model/user_session.dart';
import 'package:test/test.dart';

import 'providers/mock_authentication_provider.dart';

AuthenticationRepository mockRepository() {
  final mockUserSession = UserSession(
    username: "mock",
    email: "mock@gmail.com",
  );
  final mockProvider = MockAuthenticationProvider(userSession: mockUserSession);
  return AuthenticationRepository(mockProvider);
}

void main() {
  group('AuthenticationRepository', () {
    test('Should return a valid UserSession', () async {
      final repo = mockRepository();
      final result = await repo.signIn(
          "email", MockAuthenticationProvider.successPassword);
      assert(result != null);
    });

    test('Should throw if UserSession comes null from provider', () async {
      final repo = mockRepository();
      try {
        await repo
            .signIn("email", "incorrect password")
            .then((userSession) {
          fail("Should throw an exception");
        });
      } catch (error) {
        assert(error.toString() == "Failed to authenticate");
      }
    });
  });
}
