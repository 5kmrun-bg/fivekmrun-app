import 'package:fivekmrun_flutter/common/profile_switcher_sheet.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
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

/// Avoids exercising StravaResource.deAuthenticate's real strava_client/
/// Firebase Crashlytics calls, which need a real Firebase app — same pattern
/// used in test/common/profile_switcher_test.dart.
class _NoOpStravaResource extends StravaResource {
  @override
  Future<void> deAuthenticate() async {}
}

final _offlineFallbackClient =
    MockClient((_) async => throw http.ClientException("offline"));

/// Builds a full app (rather than [localizedApp]'s bare `Scaffold`) so that
/// `pushNamed('add-profile'/'manage-profiles')` from inside the sheet has
/// real named routes to resolve against.
Widget _harness({
  required AuthenticationResource authRes,
  required void Function(BuildContext) captureContext,
}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>.value(
          value: UserResource(client: _offlineFallbackClient)),
      ChangeNotifierProvider<RunsResource>.value(
          value: RunsResource(client: _offlineFallbackClient)),
      ChangeNotifierProvider<StravaResource>.value(
          value: _NoOpStravaResource()),
      ChangeNotifierProvider<LocalStorageResource>.value(
          value: LocalStorageResource()),
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
      routes: {
        'add-profile': (_) => const Scaffold(body: Text('Add profile page')),
        'manage-profiles': (_) =>
            const Scaffold(body: Text('Manage profiles page')),
      },
      home: Scaffold(
        body: Builder(builder: (context) {
          captureContext(context);
          return const SizedBox();
        }),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('showProfileSwitcherSheet', () {
    testWidgets(
        'lists every saved profile, marking the active one and falling '
        'back to the user id when a profile has no display name',
        (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111, makeActive: false);
      await authRes.authenticateWithUserId(222);
      await authRes.updateProfileDisplay(222, name: 'Kid', avatarUrl: '');

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      expect(find.text('Профили'), findsOneWidget);
      // Profile 111 has no name set, so it falls back to its id.
      expect(find.text('111'), findsOneWidget);
      expect(find.text('Kid'), findsOneWidget);

      // Only the active profile (222) shows the check mark.
      expect(find.byIcon(Icons.check), findsOneWidget);
      final activeRow = tester.widget<ListTile>(find.ancestor(
        of: find.text('Kid'),
        matching: find.byType(ListTile),
      ));
      expect(activeRow.trailing, isNotNull);
      final inactiveRow = tester.widget<ListTile>(find.ancestor(
        of: find.text('111'),
        matching: find.byType(ListTile),
      ));
      expect(inactiveRow.trailing, isNull);
    });

    testWidgets('shows the id-only vs password subtitle per profile type',
        (tester) async {
      final expiredTimestamp = DateTime.now()
          .subtract(const Duration(days: 31))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        '5kmrun_Profiles': '['
            '{"userId":111,"type":"idOnly","token":null,"tokenTimestamp":null,'
            '"username":null,"name":"","avatarUrl":""},'
            '{"userId":222,"type":"password","token":"tok",'
            '"tokenTimestamp":$expiredTimestamp,'
            '"username":"kid@example.com","name":"Kid","avatarUrl":""}'
            ']',
        '5kmrun_ActiveProfileId': 111,
      });
      final authRes = AuthenticationResource();
      await authRes.loadFromLocalStore();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      expect(find.text('Само номер'), findsOneWidget);
      expect(find.text('Парола'), findsOneWidget);
    });

    testWidgets(
        '"Add profile" is enabled below the profile cap and disabled at it',
        (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(1, makeActive: false);
      await authRes.authenticateWithUserId(2);

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      final addTile = tester.widget<ListTile>(find.ancestor(
        of: find.text('Добави профил'),
        matching: find.byType(ListTile),
      ));
      expect(addTile.enabled, isTrue);
    });

    testWidgets('"Add profile" is disabled once the profile cap is reached',
        (tester) async {
      final authRes = AuthenticationResource();
      for (var i = 0; i < 5; i++) {
        await authRes.authenticateWithUserId(i, makeActive: false);
      }

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      final addTile = tester.widget<ListTile>(find.ancestor(
        of: find.text('Добави профил'),
        matching: find.byType(ListTile),
      ));
      expect(addTile.enabled, isFalse);
    });

    testWidgets('tapping "Add profile" closes the sheet and navigates to it',
        (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Добави профил'));
      await tester.pumpAndSettle();

      expect(find.text('Add profile page'), findsOneWidget);
      // The sheet itself is gone.
      expect(find.text('Профили'), findsNothing);
    });

    testWidgets(
        'tapping "Manage profiles" closes the sheet and navigates to it',
        (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Управление на профили'));
      await tester.pumpAndSettle();

      expect(find.text('Manage profiles page'), findsOneWidget);
      expect(find.text('Профили'), findsNothing);
    });

    testWidgets('tapping the already-active profile row does nothing',
        (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      await tester.tap(find.text('111'));
      await tester.pumpAndSettle();

      // The sheet is still open — the disabled row's onTap is null, so
      // nothing dismissed it.
      expect(find.text('Профили'), findsOneWidget);
    });

    testWidgets(
        'tapping a non-active profile row switches to it and closes the '
        'sheet', (tester) async {
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111, makeActive: false);
      await authRes.authenticateWithUserId(222);

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      showProfileSwitcherSheet(ctx);
      await tester.pumpAndSettle();

      await tester.tap(find.text('111'));
      await tester.pumpAndSettle();

      expect(find.text('Профили'), findsNothing);
      expect(authRes.getUserId(), 111);
    });
  });
}
