import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/login/login_with_id.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A MockClient that always throws keeps UserResource.getById on its
// offline-fallback path, which never calls FirebaseAnalytics — same trick
// used in test/state/user_resource_test.dart.
UserResource _offlineUserResource() =>
    UserResource(client: MockClient((_) async => throw http.ClientException("offline")));

Widget _harness({
  required AuthenticationResource auth,
  required UserResource user,
  bool addingProfile = false,
}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: auth),
      ChangeNotifierProvider<UserResource>.value(value: user),
    ],
    child: MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        'loginPreview': (context) => const Scaffold(body: Text('preview')),
      },
      home: Scaffold(body: LoginWithId(addingProfile: addingProfile)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginWithId', () {
    testWidgets('shows an error and does not authenticate on invalid input',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      final user = _offlineUserResource();
      await tester.pumpWidget(_harness(auth: auth, user: user));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid personal id'), findsOneWidget);
      expect(auth.profiles, isEmpty);
    });

    testWidgets(
        'authenticates with the parsed id and navigates to loginPreview',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      final user = _offlineUserResource();
      await tester.pumpWidget(_harness(auth: auth, user: user));

      await tester.enterText(find.byType(TextField), '13731');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(auth.getUserId(), 13731);
      expect(user.currentUserId, 13731);
      expect(find.text('preview'), findsOneWidget);
    });

    testWidgets(
        'ignores surrounding whitespace and leading zeros are still parsed',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      final user = _offlineUserResource();
      await tester.pumpWidget(_harness(auth: auth, user: user));

      await tester.enterText(find.byType(TextField), '  42  ');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(auth.getUserId(), 42);
    });

    group('addingProfile: true', () {
      testWidgets(
          'adds an id-only profile without switching the active one, then pops true',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthenticationResource();
        await auth.authenticateWithUserId(111); // existing active profile
        final user = _offlineUserResource();

        bool? poppedWith;
        await tester.pumpWidget(MultiProvider(
          providers: <ChangeNotifierProvider<dynamic>>[
            ChangeNotifierProvider<AuthenticationResource>.value(value: auth),
            ChangeNotifierProvider<UserResource>.value(value: user),
          ],
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
                        builder: (_) => Scaffold(
                          body: LoginWithId(addingProfile: true),
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

        await tester.enterText(find.byType(TextField), '222');
        await tester.tap(find.byType(ElevatedButton).last);
        await tester.pumpAndSettle();

        expect(auth.getUserId(), 111); // still the original active profile
        expect(auth.profiles.map((p) => p.userId), containsAll([111, 222]));
        expect(poppedWith, isTrue);
      });

      testWidgets(
          'shows a max-profiles message and does not pop when the cap is reached',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        final auth = AuthenticationResource();
        for (var id = 1; id <= 5; id++) {
          await auth.authenticateWithUserId(id, makeActive: false);
        }
        final user = _offlineUserResource();

        await tester.pumpWidget(_harness(auth: auth, user: user, addingProfile: true));

        await tester.enterText(find.byType(TextField), '999');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(find.text('Maximum number of profiles reached (5)'),
            findsOneWidget);
        expect(auth.profiles, hasLength(5));
        expect(auth.profiles.map((p) => p.userId), isNot(contains(999)));
      });
    });
  });
}
