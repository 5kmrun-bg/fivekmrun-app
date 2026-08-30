import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/settings_page.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Avoids exercising StravaResource.deAuthenticate's real strava_client call
/// (which needs a fully configured OAuth client) — same pattern as
/// test/common/profile_switcher_test.dart's identical helper.
class _NoOpStravaResource extends StravaResource {
  @override
  Future<void> deAuthenticate() async {}
}

// UserResource/RunsResource's success paths need a real Firebase app —
// throwing (simulating "offline") keeps them on the safe fallback path, same
// pattern as test/common/profile_switcher_test.dart.
final _offlineFallbackClient =
    MockClient((_) async => throw http.ClientException("offline"));

/// Stands in for profile.dart: pushes SettingsPage on the *root* navigator
/// exactly the way `goToSettings` does there, so this test can assert on
/// what's actually left in the stack after sign-out (a bare `home:` widget
/// can't stand in for that — there'd be nothing for the root-navigator pop
/// to reveal).
class _ProfileHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('profile-screen'),
          ElevatedButton(
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
            child: const Text('open settings'),
          ),
        ],
      ),
    );
  }
}

/// With the app's real localization delegates so `AppLocalizations.of`
/// resolves, and a named "/" route for `removeProfileFromSwitcher`'s
/// no-profiles-left path to land on — mirrors test/localized_app.dart but
/// adds that, which the shared helper doesn't support.
Widget _harness({
  required AuthenticationResource authRes,
  required UserResource userRes,
  required RunsResource runsRes,
}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>.value(value: userRes),
      ChangeNotifierProvider<RunsResource>.value(value: runsRes),
      ChangeNotifierProvider<StravaResource>.value(value: _NoOpStravaResource()),
      ChangeNotifierProvider<LocaleProvider>.value(value: LocaleProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('bg'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // A relative initial route (no leading "/") skips Flutter's
      // deep-link-style initial-route generation, which would otherwise
      // seed "/" beneath it regardless of whether anything ever navigates
      // there — see the note this replaced for how that bit before.
      initialRoute: 'profile',
      routes: <String, WidgetBuilder>{
        '/': (_) => const Scaffold(body: Text('login-screen')),
        'profile': (_) => _ProfileHarness(),
      },
    ),
  );
}

/// SettingsPage.build() creates a fresh LocalStorageResource() and calls
/// setState from its future's `.then()` on every build, unconditionally —
/// so it reschedules another build every single time and pumpAndSettle
/// never quiesces. A bounded number of pumps is enough for our async chains
/// (SharedPreferences/mocked HTTP) to resolve without hitting that loop.
Future<void> _pumpBounded(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsPage sign-out', () {
    testWidgets(
        'with another saved profile, signing out falls back to it and '
        'returns to the profile screen', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(13731);
      await authRes.authenticateWithUserId(18880, makeActive: false);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);

      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
      ));
      await _pumpBounded(tester);

      await tester.tap(find.text('open settings'));
      await _pumpBounded(tester);
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.exit_to_app));
      await _pumpBounded(tester);

      // The other saved profile must survive sign-out and become active...
      expect(authRes.profiles.map((p) => p.userId), contains(18880));
      expect(authRes.getUserId(), 18880);
      // ...and Settings must close back to the profile screen — staying put
      // gives no indication the active profile actually changed.
      expect(find.byType(SettingsPage), findsNothing);
      expect(find.text('profile-screen'), findsOneWidget);
    });

    testWidgets('with no other saved profile, signing out goes to login',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(13731);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);

      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
      ));
      await _pumpBounded(tester);

      await tester.tap(find.text('open settings'));
      await _pumpBounded(tester);

      await tester.tap(find.byIcon(Icons.exit_to_app));
      await _pumpBounded(tester);

      expect(authRes.profiles, isEmpty);
      expect(find.text('login-screen'), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
      expect(find.text('profile-screen'), findsNothing);
    });
  });
}
