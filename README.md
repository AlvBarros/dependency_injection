# Dependency Injection in Flutter

According to [Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection):

> In software engineering, **dependency injection** is a design pattern in which an object or function receives other objects or functions that it depends on. A form of inversion of control, dependency injection aims to separate the concerns of constructing objects and using them, leading to loosely coupled programs. The pattern ensures that an object or function which wants to use a given service should not have to know how to construct those services. Instead, the receiving 'client' (object or function) is provided with its dependencies by external code (an 'injector'), which it is not aware of.

## In other words:

- Instead of creating objects inside a class or method, those objects are **"injected" from outside**;
- The class **does not** need to know how to create the objects it depends on, it just needs to know how to use them;
- This generates code that is **easier to test** and is **more maintainable**.

## Benefits:

- Makes your code **easier to test**, since you can just inject mocks in your classes;
- Makes your code **easier to maintain**, as changes to the implementation of the injected objects can be made without affecting the class or method that depends on them.

## Drawbacks _(more like risks)_:

- DI can **add more complexity** to your project, especially if done improperly;
- Injecting dependencies can introduce **performance overhead**;
- DI can introduce **runtime errors**, such as null pointer exceptions, if dependencies are not properly managed or injected.

## Example

Suppose you have a Car class, that has an Engine.

```dart car.dart
class Car {
    Engine? engine;
    const Car();

    void start() {
        _engine.start(); // Null reference exception
    }
}
```

For this Car to work, you need a working Engine. That, however, is another class that has a bunch of complexities and other requirements that do not concern the car itself.

Following the principles of **dependency injection**, this is what we can do:

- **Constructor injection**

The dependencies are passed to a class through its constructor.

This pattern makes it it clear what dependencies a class require to function, and it ensures that the dependencies are available as soon as the class is created.

If we implement constructor injection in our `Car` class:

```dart car.dart
class Car {
    final Engine engine;
    const Car(this.engine);

    void start() {
        engine.start(); // engine is not null!
    }
}
```

Since `Car.engine` is `final` and also required in the constructor, we make sure that it will never be null, and therefore will always work.

```dart main.dart
void main() {
    var engine = Engine();
    var car = Car(engine);
    car.start();
}
```

Now let's imagine that you're a car manufacturer and is creating parts of a car. Since cars are not only made of engines, you now have this new class structure:

```dart car.dart
class Car {
    final Engine engine;
    final List<Wheel> wheels;
    final List<Door> doors;
    final List<Window> windows;
    Car(this.engine, this.wheels, this.doors, this.windows);

    void start() {
        engine.start();
    }

    void rollDownAllWindows() {
        for (var w in windows) {
            w.rollDown();
        }
    }

    void openAllDors() {
        for (var d in doors) {
            d.open();
        }
    }

    // ...
}
```

Since the engine is `final` and must be passed on in the constructor, the class won't compile until you give it a working engine. It doesn't make sense that your doors doesn't work until you have a working engine.

> With the construction injection approach, you're only able to have a car after you have all the pieces already done, and can not have an "incomplete" car.

- **Setter injection**

The dependencies are set on a class through setter methods.

This pattern allows for more flexibility as the dependencies can be set or changed after the class is created.

Whenever you have an instance of Car, you can just use `setEngine` to set an engine to the car. This fixes the previous problem: now we can have a Car and later give it an engine.

```dart car.dart
class Car {
    Engine? engine;
    List<Wheel> wheels;
    List<Door> doors;
    List<Window> windows;
    Car(this.wheels, this.doors, this.windows, {this.engine});

    void setEngine(Engine newEngine) {
        engine = newEngine;
    }

    void start() {
        engine?.start();
    }

    void rollDownAllWindows() {
        for (var w in windows) {
            w.rollDown();
        }
    }

    void openAllDors() {
        for (var d in doors) {
            d.open();
        }
    }

    // ...
}
```

Now all you have to do is call `setEngine` whenever your engine is ready to be placed in the car. You also must add some validation so that you don't have runtime errors happening in your code.

There's a bunch of different other types of DI that are not going to be covered in this article. Some of them are:

- **Interface injection**

The class implements an interface which defines the methods for injecting the dependenciess

This pattern allows for more abstraction and decoupling of the code, as the class does not have to depend on a specific implementation of the interface.

- **Ambient context**

> _You may be familiar with the [provider pub package](https://pub.dev/packages/provider)_

A shared context is used to provide the dependencies to the classes that require them.

This pattern can be useful in situations where multiple classes need access to the same dependencies.

- **Service locator**

> _You may be familiar with the [get_it pub package](https://pub.dev/packages/get_it)._

A central registry is used to manage and provide the dependencies to the classes that require them.

This pattern can make it easier to manage dependencies in large applications, but it can also make the code more complex and harded to test.

## Real life example and implementation

In my [OneDart project](), I need to create an authentication layer so that my users can create accounts and authenticate themselves.

Since I was still deciding on which one to use, I created a dependency injection structure so that I can easily swap out whenever I'd like to test another authentication service.

This is the structure that I've got:

```dart authentication_repository.dart
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

    // ...
}
```

This class has a method `signIn` that takes an user's _email_ and _password_, then give it to the corresponding provider. It also returns an `UserSession`, class responsible to store the current user's data and authentication token.

```dart UserSession.dart
class UserSession {
  final String username;
  final String email;

  UserSession({
    required this.username,
    required this.email,
  });

  String get sessionToken => "";
}
```

In this class, `sessionToken` would be the `Autheorization` header we're supposed to send to our RESTful API.

Take notice of `AuthenticationRepository.provider`. It's an instance of the class `AuthenticationProvider`. Here's the implementation:

```dart authentication_provider.dart
abstract class AuthenticationProvider {
    Future<UserSession?> signIn(String email, String password);
}
```

Since this class is abstract, in order to create a repository that actually works, you need to give it an implementation.

So I have created two classes: `FirebaseProvider` and `CognitoProvider`. These classes are responsible for managing user authentication with Firebase's authentication and AWS Cognito's authentication respectively.

```dart FirebaseProvider
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
```

This `signIn` method uses the implementation of the package [firebase_core](https://pub.dev/packages/firebase_core), if you'd like to get more info. For now, let's focus on DI.

This method, however, now returns a `FirebaseSession`. This class is an extension of `UserSession` as previously mentioned, because Firebase works differntly with authentication than other providers. Let's take a look:

```dart firebase_session.dart
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
```

It is still, however, working with `UserSession.sessionToken`. So the `Authorization` header can work as normal.

Now, let's take a look at `CognitoProvider`:

```dart cognito_provider.dart
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
```

This provider makes use of the package [amazon_cognito_identity_dart_2](https://pub.dev/packages/amazon_cognito_identity_dart_2) to authenticate with AWS.

Pay attention that `CognitoProvider.signIn` returns an instance of `CognitoSession`:

```dart cognito_session.dart
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
```

And there it is, the same implementation for `sessionToken`.

So now, in order to authenticate, we just need to decide which one we want to use and it'll work properly _(assuming our backend can work with both providers)_:

```dart main.dart
void main() {
    final authRepository = AuthenticationRepository(CognitoProvider()); // change this parameter
    authRepository.signIn("cognito@gmail.com", "password123");
}
```

## Testing example

To showcase how you can use dependency injection to make better tests, here's an example of a `MockAuthenticationProvider` that enables testing on `AuthenticationRepository`.

You begin by creating the mocked provider:

```dart mock_authentication_provider.dart
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
```

Note that the class above has a static `successPassword` property. This is so that we can implement success and failure methods, but it is in no way necessary. Feel free to implement any logic that you'd like.

And now you can then create the mock factory:

```dart authentication_repository_test.dart
AuthenticationRepository mockRepository() {
  final mockUserSession = UserSession(
    username: "mock",
    email: "mock@mail.com",
  );
  final mockProvider = MockAuthenticationProvider(userSession: mockUserSession);
  return AuthenticationRepository(mockProvider);
}
```

By using this `AuthenticationRepository`, we can easily test its methods without needing to integrate with either Cognito nor Firebase. Here's an example of a successful unit test:

```dart authentication_repository_test.dart
test('Should return a valid UserSession', () async {
    final repo = mockRepository();
    final result = await repo.signIn(
        "email", MockAuthenticationProvider.successPassword);
    assert(result != null);
});
```

Note that we're trying to signin with an `"email"` and `MockAuthenticationProvider.successPassword`, which is a way to force the provider to return an `UserSession`.

Now, testing for failures:

```dart authentication_repository_test.dart
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
```