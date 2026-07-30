import 'dart:convert';

import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/offline_chart/offline_chart_page.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/offline_results_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

// UserResource's success path needs a real Firebase app — throwing
// (simulating "offline") keeps it on the safe fallback path, same pattern as
// test/common/profile_switcher_test.dart.
final _offlineFallbackClient =
    MockClient((_) async => throw http.ClientException("offline"));

/// Hosts OfflineChartPage behind a named route, with the app's real
/// localization delegates, so the "participate" flow's un-authenticated
/// path (which navigates to the root-level "/" route) has somewhere to
/// land — mirrors ../localized_app.dart but adds named routes, which that
/// helper doesn't support.
Widget _harness({
  required AuthenticationResource authRes,
  required UserResource userRes,
  required RunsResource runsRes,
  required OfflineResultsResource resource,
}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>.value(value: userRes),
      ChangeNotifierProvider<RunsResource>.value(value: runsRes),
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
      initialRoute: '/home',
      routes: <String, WidgetBuilder>{
        '/': (_) => const Scaffold(body: Text('login-screen')),
        '/home': (_) => OfflineChartPage(
              thisWeekResource: resource,
              lastWeekResource: resource,
            ),
      },
    ),
  );
}

void main() {
  testWidgets(
      'wires a RefreshIndicator so pull-to-refresh reloads the current week',
      (tester) async {
    final client = MockClient((_) async =>
        http.Response(jsonEncode({"runners": []}), 200, headers: _jsonHeaders));

    await tester.pumpWidget(localizedApp(OfflineChartPage(
      thisWeekResource: OfflineResultsResource(client: client),
      lastWeekResource: OfflineResultsResource(client: client),
    )));
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('reloads results when the RefreshIndicator is triggered',
      (tester) async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      return http.Response(jsonEncode({"runners": []}), 200,
          headers: _jsonHeaders);
    });

    await tester.pumpWidget(localizedApp(OfflineChartPage(
      thisWeekResource: OfflineResultsResource(client: client),
      lastWeekResource: OfflineResultsResource(client: client),
    )));
    await tester.pumpAndSettle();

    final requestsBeforeRefresh = requestCount;

    await tester.fling(
        find.byType(RefreshIndicator), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(requestCount, greaterThan(requestsBeforeRefresh));
  });

  group('participating with an unauthenticated active profile', () {
    testWidgets(
        'prompting to authenticate leaves other saved profiles untouched',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      // Active profile has no token (ID-only) — participating requires a
      // password, per goToAddEntry()'s isLoggedIn() gate.
      await authRes.authenticateWithUserId(13731);
      await authRes.authenticateWithUserId(18880, makeActive: false);

      final userRes = UserResource(client: _offlineFallbackClient);
      final runsRes = RunsResource(client: _offlineFallbackClient);
      final resource = OfflineResultsResource(
        client: MockClient((_) async =>
            http.Response(jsonEncode({"runners": []}), 200,
                headers: _jsonHeaders)),
      );

      await tester.pumpWidget(_harness(
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        resource: resource,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Участвай'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Вход с парола'));
      await tester.pumpAndSettle();

      // The other saved profile must survive — only the active profile's
      // own authentication state should change.
      expect(authRes.profiles.map((p) => p.userId), contains(18880));
    });
  });
}
