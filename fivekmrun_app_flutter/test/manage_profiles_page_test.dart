import 'package:fivekmrun_flutter/manage_profiles_page.dart';
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

import 'localized_app.dart';

/// Same rationale as profile_switcher_test.dart's identically-named class:
/// avoids exercising StravaResource.deAuthenticate's real strava_client call,
/// which needs a fully configured OAuth client.
class _NoOpStravaResource extends StravaResource {
  @override
  Future<void> deAuthenticate() async {}
}

final _offlineFallbackClient =
    MockClient((_) async => throw http.ClientException("offline"));

Widget _harness(AuthenticationResource authRes) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>(
          create: (_) => UserResource(client: _offlineFallbackClient)),
      ChangeNotifierProvider<RunsResource>(
          create: (_) => RunsResource(client: _offlineFallbackClient)),
      ChangeNotifierProvider<StravaResource>(
          create: (_) => _NoOpStravaResource()),
      ChangeNotifierProvider<LocalStorageResource>(
          create: (_) => LocalStorageResource()),
    ],
    child: localizedApp(const ManageProfilesPage()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('lists every saved profile with name, type, and avatar '
      'fallbacks', (tester) async {
    final authRes = AuthenticationResource();
    await authRes.authenticateWithUserId(111);
    await authRes.authenticateWithUserId(222, makeActive: false);
    // Give profile 222 a display name so it exercises the non-fallback path.
    authRes.updateProfileDisplay(222, name: "Kid", avatarUrl: "");

    await tester.pumpWidget(_harness(authRes));
    await tester.pump();

    // 111 has no cached name yet -> falls back to showing the user id.
    expect(find.text("111"), findsOneWidget);
    expect(find.text("Kid"), findsOneWidget);

    // idOnly profiles show the "id only" subtitle, not "password".
    expect(find.text("Само номер"), findsNWidgets(2));
  });

  testWidgets('highlights the active profile as selected', (tester) async {
    final authRes = AuthenticationResource();
    await authRes.authenticateWithUserId(111);
    await authRes.authenticateWithUserId(222, makeActive: false);

    await tester.pumpWidget(_harness(authRes));
    await tester.pump();

    final activeTile =
        tester.widget<ListTile>(find.widgetWithText(ListTile, "111"));
    final inactiveTile =
        tester.widget<ListTile>(find.widgetWithText(ListTile, "222"));

    expect(activeTile.selected, isTrue);
    expect(inactiveTile.selected, isFalse);
  });

  testWidgets('cancelling the remove confirmation keeps the profile',
      (tester) async {
    final authRes = AuthenticationResource();
    await authRes.authenticateWithUserId(111);
    await authRes.authenticateWithUserId(222, makeActive: false);

    await tester.pumpWidget(_harness(authRes));
    await tester.pump();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline)
        .at(1)); // the second row (222)
    await tester.pumpAndSettle();

    expect(find.text("Премахни профила?"), findsOneWidget);
    expect(
        find.text("Сигурни ли сте, че искате да премахнете профила на 222?"),
        findsOneWidget);

    await tester.tap(find.text("Отказ"));
    await tester.pumpAndSettle();

    expect(authRes.profiles, hasLength(2));
    expect(find.text("222"), findsOneWidget);
  });

  testWidgets(
      'confirming removal of a non-active profile removes it without '
      'reloading', (tester) async {
    final authRes = AuthenticationResource();
    await authRes.authenticateWithUserId(111);
    await authRes.authenticateWithUserId(222, makeActive: false);

    await tester.pumpWidget(_harness(authRes));
    await tester.pump();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline)
        .at(1)); // the second row (222)
    await tester.pumpAndSettle();

    await tester.tap(find.text("Премахни"));
    await tester.pumpAndSettle();

    expect(authRes.profiles, hasLength(1));
    expect(authRes.getUserId(), 111);
    expect(find.text("222"), findsNothing);
  });

  testWidgets(
      'confirming removal of the active profile falls back to the '
      'remaining one', (tester) async {
    final authRes = AuthenticationResource();
    await authRes.authenticateWithUserId(111);
    await authRes.authenticateWithUserId(222, makeActive: false);

    await tester.pumpWidget(_harness(authRes));
    await tester.pump();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline)
        .at(0)); // the first row (111, active)
    await tester.pumpAndSettle();

    await tester.tap(find.text("Премахни"));
    await tester.pumpAndSettle();

    expect(authRes.profiles, hasLength(1));
    expect(authRes.getUserId(), 222);
  });
}
