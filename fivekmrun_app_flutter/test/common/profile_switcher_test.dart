import 'package:fivekmrun_flutter/common/profile_switcher.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

/// Avoids exercising StravaResource.deAuthenticate's real strava_client call
/// (which needs a fully configured OAuth client) — same pattern as
/// UserResource's success path being untestable without a real Firebase app
/// (see test/state/user_resource_test.dart's note); only observing that it
/// was *called* matters for the "no bleed" acceptance criterion.
class _NoOpStravaResource extends StravaResource {
  bool deauthCalled = false;

  @override
  Future<void> deAuthenticate() async {
    deauthCalled = true;
  }
}

// UserResource.getById's success path calls FirebaseAnalytics, which needs a
// real Firebase app (see test/state/user_resource_test.dart) — throwing
// (simulating "offline") keeps this on the safe fallback path that assigns
// the *requested* user id, which is what proves the switch reloaded for the
// new profile rather than leaving the old one's data in place. (The other
// fallback — a non-JSON response — sets a sentinel id of -1 instead, which
// wouldn't distinguish "reloaded for 222" from "reloaded for anything".)
final _offlineFallbackClient =
    MockClient((_) async => throw http.ClientException("offline"));

Widget _harness({
  required AuthenticationResource authRes,
  required UserResource userRes,
  required RunsResource runsRes,
  required _NoOpStravaResource stravaRes,
  required LocalStorageResource localStorage,
  required void Function(BuildContext) captureContext,
}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>.value(value: userRes),
      ChangeNotifierProvider<RunsResource>.value(value: runsRes),
      ChangeNotifierProvider<StravaResource>.value(value: stravaRes),
      ChangeNotifierProvider<LocalStorageResource>.value(value: localStorage),
    ],
    child: localizedApp(Builder(builder: (context) {
      captureContext(context);
      return const SizedBox();
    })),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('switchToProfile', () {
    testWidgets(
        'switches, reloads per-user resources for the new profile, and '
        'leaves device settings untouched', (tester) async {
      SharedPreferences.setMockInitialValues(
          {'push_notifications_subscribed_general': true});

      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);
      await authRes.authenticateWithUserId(222, makeActive: false);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final stravaRes = _NoOpStravaResource();
      final localStorage = LocalStorageResource();

      // Seed with profile 111's data, as if it had already been loaded —
      // this is what must NOT bleed into profile 222 after the switch.
      userRes.currentUserId = 111;
      await tester.pump();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        stravaRes: stravaRes,
        localStorage: localStorage,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      final result = await switchToProfile(ctx, 222);
      await tester.pump();

      expect(result, isTrue);
      expect(authRes.getUserId(), 222);
      expect(userRes.value?.id, 222);
      expect(stravaRes.deauthCalled, isTrue);

      // Device-level settings are untouched by the switch.
      expect(await localStorage.isSubscribedForGeneral, isTrue);
    });

    testWidgets('returns false for an unknown profile id', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final stravaRes = _NoOpStravaResource();
      final localStorage = LocalStorageResource();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        stravaRes: stravaRes,
        localStorage: localStorage,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      final result = await switchToProfile(ctx, 999);

      expect(result, isFalse);
      expect(authRes.getUserId(), 111);
      expect(stravaRes.deauthCalled, isFalse);
    });

    testWidgets(
        'an expired password profile prompts for its password before '
        'completing the switch', (tester) async {
      final expiredTimestamp = DateTime.now()
          .subtract(const Duration(days: 31))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'push_notifications_subscribed_general': true,
        '5kmrun_Profiles': '['
            '{"userId":111,"type":"idOnly","token":null,"tokenTimestamp":null,'
            '"username":null,"name":"","avatarUrl":""},'
            '{"userId":222,"type":"password","token":"stale",'
            '"tokenTimestamp":$expiredTimestamp,'
            '"username":"kid@example.com","name":"Kid","avatarUrl":""}'
            ']',
        '5kmrun_ActiveProfileId': 111,
      });
      final authRes = AuthenticationResource();
      await authRes.loadFromLocalStore();
      expect(authRes.profiles.firstWhere((p) => p.userId == 222).isTokenExpired,
          isTrue);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final stravaRes = _NoOpStravaResource();
      final localStorage = LocalStorageResource();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        stravaRes: stravaRes,
        localStorage: localStorage,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      // Not awaited: the dialog blocks until dismissed, and this test only
      // needs to observe that it appeared.
      switchToProfile(ctx, 222);
      await tester.pump();
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      // The switch has not completed yet — still on the original profile.
      expect(authRes.getUserId(), 111);

      // Dismiss it (Cancel) so the test doesn't leak a pending dialog.
      await tester.tap(find.text('Отказ'));
      await tester.pumpAndSettle();
    });
  });

  group('removeProfileFromSwitcher', () {
    testWidgets(
        'removing the active profile falls back to another and '
        'reloads for it', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);
      await authRes.authenticateWithUserId(222, makeActive: false);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final stravaRes = _NoOpStravaResource();
      final localStorage = LocalStorageResource();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        stravaRes: stravaRes,
        localStorage: localStorage,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      await removeProfileFromSwitcher(ctx, 111);
      await tester.pump();

      expect(authRes.getUserId(), 222);
      expect(userRes.value?.id, 222);
      expect(authRes.profiles, hasLength(1));
    });

    testWidgets('removing a non-active profile does not reload anything',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);
      await authRes.authenticateWithUserId(222, makeActive: false);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final stravaRes = _NoOpStravaResource();
      final localStorage = LocalStorageResource();

      late BuildContext ctx;
      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        stravaRes: stravaRes,
        localStorage: localStorage,
        captureContext: (c) => ctx = c,
      ));
      await tester.pump();

      await removeProfileFromSwitcher(ctx, 222);
      await tester.pump();

      expect(authRes.getUserId(), 111);
      expect(stravaRes.deauthCalled, isFalse);
    });
  });
}
