import 'dart:convert';

import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

// Same shape events_resource_test.dart uses: one object carrying every key
// the future/past/XL/kids parsers read, so it works for whichever endpoint
// AllFutureEventsResource/AllPastEventsResource hits.
final _eventsBody = jsonEncode([
  {
    "e_id": 1,
    "e_title": "Race",
    "e_date": 1609459200,
    "e_time": "09:00",
    "n_name": "Sofia",
    "e_sponsor": "logo.png",
  }
]);

/// Answers every request with a valid, empty-but-parseable JSON payload.
///
/// UserResource.getById's success path calls FirebaseAnalytics.instance,
/// which throws without a real Firebase app — same constraint documented in
/// test/settings_page_test.dart's `_offlineFallbackClient`. So this client is
/// only safe to hand to the runs/events resources, never to UserResource.
MockClient _emptyRunsClient() => MockClient((request) async {
      if (request.url.path.contains("xlrun")) {
        return http.Response("<html>not found</html>", 200,
            headers: {"content-type": "text/html; charset=utf-8"});
      }
      if (request.url.path.contains("selfie")) {
        return http.Response(jsonEncode({"runs": []}), 200,
            headers: _jsonHeaders);
      }
      return http.Response(jsonEncode({"runners": []}), 200,
          headers: _jsonHeaders);
    });

MockClient _eventsClient() =>
    MockClient((_) async => http.Response(_eventsBody, 200, headers: _jsonHeaders));

/// Simulates "no internet" — every resource's fetch either swallows this
/// internally (UserResource.getById) or rethrows it for [reportOnFailure] to
/// swallow (RunsResource, the events resources).
final _offlineClient =
    MockClient((_) async => throw http.ClientException("offline"));

Future<BuildContext> _pumpHarness(
  WidgetTester tester, {
  required AuthenticationResource authRes,
  required UserResource userRes,
  required RunsResource runsRes,
  required AllFutureEventsResource futureEventsRes,
  required AllPastEventsResource pastEventsRes,
}) async {
  late BuildContext captured;
  await tester.pumpWidget(MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<AuthenticationResource>.value(value: authRes),
      ChangeNotifierProvider<UserResource>.value(value: userRes),
      ChangeNotifierProvider<RunsResource>.value(value: runsRes),
      ChangeNotifierProvider<AllFutureEventsResource>.value(
          value: futureEventsRes),
      ChangeNotifierProvider<AllPastEventsResource>.value(
          value: pastEventsRes),
    ],
    child: MaterialApp(
      home: Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      }),
    ),
  ));
  return captured;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('refreshAllData', () {
    testWidgets(
        'skips the user/runs fetch but still refreshes events when no profile is active',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      var runsFetched = false;
      final authRes = AuthenticationResource();
      final userRes = UserResource(client: _offlineClient);
      final runsRes = RunsResource(
          client: MockClient((request) async {
        runsFetched = true;
        return http.Response(jsonEncode({"runners": []}), 200,
            headers: _jsonHeaders);
      }));
      final futureEventsRes = AllFutureEventsResource(client: _eventsClient());
      final pastEventsRes = AllPastEventsResource(client: _eventsClient());

      final context = await _pumpHarness(
        tester,
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        futureEventsRes: futureEventsRes,
        pastEventsRes: pastEventsRes,
      );

      await refreshAllData(context);

      expect(runsFetched, isFalse);
      expect(userRes.value, isNull);
      expect(futureEventsRes.value, isNotEmpty);
      expect(pastEventsRes.value, isNotEmpty);
    });

    testWidgets(
        'refreshes runs and events for the active profile without throwing when the user fetch fails',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(111);
      final userRes = UserResource(client: _offlineClient);
      final runsRes = RunsResource(client: _emptyRunsClient());
      final futureEventsRes = AllFutureEventsResource(client: _eventsClient());
      final pastEventsRes = AllPastEventsResource(client: _eventsClient());

      final context = await _pumpHarness(
        tester,
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        futureEventsRes: futureEventsRes,
        pastEventsRes: pastEventsRes,
      );

      await refreshAllData(context);

      // UserResource.getById swallows the offline error internally and
      // falls back to a cached-id-only User rather than leaving value null.
      expect(userRes.value, isNotNull);
      expect(userRes.value!.id, 111);
      expect(runsRes.value, isNotNull);
      expect(futureEventsRes.value, isNotEmpty);
      expect(pastEventsRes.value, isNotEmpty);
    });

    testWidgets(
        'completes without throwing when every resource fails, keeping prior values',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authRes = AuthenticationResource();
      await authRes.authenticateWithUserId(222);
      final userRes = UserResource(client: _offlineClient);
      final runsRes = RunsResource(client: _offlineClient);
      final futureEventsRes = AllFutureEventsResource(client: _offlineClient);
      final pastEventsRes = AllPastEventsResource(client: _offlineClient);

      final context = await _pumpHarness(
        tester,
        authRes: authRes,
        userRes: userRes,
        runsRes: runsRes,
        futureEventsRes: futureEventsRes,
        pastEventsRes: pastEventsRes,
      );

      // The key assertion: reportOnFailure's per-resource try/catch plus
      // Future.wait(eagerError: false) mean one dead endpoint never becomes
      // an unhandled exception here, even with every resource offline.
      await expectLater(refreshAllData(context), completes);

      expect(runsRes.value, isNull);
      expect(futureEventsRes.value, isEmpty);
      expect(pastEventsRes.value, isEmpty);
    });
  });

  group('reportOnFailure', () {
    test('swallows a thrown error instead of rethrowing it', () async {
      await expectLater(
        reportOnFailure(Future<void>.error(Exception('boom')), 'test'),
        completes,
      );
    });

    test('lets a successful future resolve normally', () async {
      var ran = false;
      await reportOnFailure(Future(() => ran = true), 'test');

      expect(ran, isTrue);
    });
  });
}
