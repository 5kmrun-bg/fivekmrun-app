import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/login/login_with_username.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overrides the network call so the widget's success/failure/error
/// branches can be driven directly, without a real `dart:io` HttpClient —
/// same subclass-and-override trick as `_NoOpStravaResource` in
/// test/common/profile_switcher_test.dart.
class _FakeAuthenticationResource extends AuthenticationResource {
  bool authenticateCalled = false;
  String? lastUsername;
  String? lastPassword;
  bool? lastMakeActive;

  /// Returned by [authenticate] when [errorToThrow] is null.
  bool result = true;

  /// Thrown by [authenticate] instead of returning [result], when set.
  Object? errorToThrow;

  @override
  Future<bool> authenticate(String username, String password,
      {bool makeActive = true}) async {
    authenticateCalled = true;
    lastUsername = username;
    lastPassword = password;
    lastMakeActive = makeActive;

    if (errorToThrow != null) throw errorToThrow!;
    return result;
  }
}

Widget _harness({
  required AuthenticationResource auth,
  bool addingProfile = false,
}) {
  return ChangeNotifierProvider<AuthenticationResource>.value(
    value: auth,
    child: MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        'home': (context) => const Scaffold(body: Text('home')),
      },
      home: Scaffold(body: LoginWithUsername(addingProfile: addingProfile)),
    ),
  );
}

Future<void> _enterCredentials(WidgetTester tester,
    {String username = 'runner@example.com', String password = 'secret'}) async {
  await tester.enterText(find.byType(TextField).first, username);
  await tester.enterText(find.byType(TextField).last, password);
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginWithUsername', () {
    testWidgets(
        'a successful login (not adding a profile) replaces the stack with '
        'home', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource();
      await tester.pumpWidget(_harness(auth: auth));

      await _enterCredentials(tester);

      expect(auth.authenticateCalled, isTrue);
      expect(auth.lastMakeActive, isTrue);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('trims surrounding whitespace from the username',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource();
      await tester.pumpWidget(_harness(auth: auth));

      await _enterCredentials(tester, username: '  runner@example.com  ');

      expect(auth.lastUsername, 'runner@example.com');
    });

    testWidgets(
        'a successful login while adding a profile pops true instead of '
        'navigating to home', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource();

      bool? poppedWith;
      await tester.pumpWidget(ChangeNotifierProvider<AuthenticationResource>.value(
        value: auth,
        child: MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                child: const Text('open'),
                onPressed: () async {
                  poppedWith = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: LoginWithUsername(addingProfile: true),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await _enterCredentials(tester);

      expect(auth.lastMakeActive, isFalse);
      expect(poppedWith, isTrue);
    });

    testWidgets('a rejected login shows the wrong-credentials error',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource()..result = false;
      await tester.pumpWidget(_harness(auth: auth));

      await _enterCredentials(tester);

      expect(find.text('Wrong username or password'), findsOneWidget);
    });

    testWidgets(
        'a request failure (e.g. no network) shows the wrong-credentials '
        'error rather than crashing', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource()
        ..errorToThrow = const FormatException('unexpected response');
      await tester.pumpWidget(_harness(auth: auth));

      await _enterCredentials(tester);

      expect(find.text('Wrong username or password'), findsOneWidget);
    });

    testWidgets(
        'hitting the profile cap while adding a profile shows the '
        'max-profiles message instead of the generic error', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = _FakeAuthenticationResource()
        ..errorToThrow = MaxProfilesReachedException();
      await tester.pumpWidget(_harness(auth: auth, addingProfile: true));

      await _enterCredentials(tester);

      expect(find.text('Maximum number of profiles reached (5)'),
          findsOneWidget);
      expect(find.text('Wrong username or password'), findsNothing);
    });
  });
}
