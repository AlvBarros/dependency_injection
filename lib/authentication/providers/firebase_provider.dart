import 'package:firebase_auth/firebase_auth.dart';

import '../../model/firebase_session.dart';
import 'authentication_provider.dart';

class FirebaseProvider implements AuthenticationProvider {
    const FirebaseProvider();

    @override
    Future<FirebaseSession?> signIn(String email, String password) async {
        final auth = FirebaseAuth.instance;

        try {
            final creds = await auth.signInWithEmailAndPassword(email: email, password: password);
            if (creds.user != null) {
                final username = creds.user!.displayName!;
                String token = await creds.user!.getIdToken(true);
                return FirebaseSession(idToken: token, username: username, email: email);
            }
            throw 'Failed to sign in with $email';
        } catch (e) {
            rethrow;
        }
    }

    // ...
}