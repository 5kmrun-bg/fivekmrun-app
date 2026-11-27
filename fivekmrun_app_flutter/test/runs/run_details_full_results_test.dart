import 'dart:convert';

import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/events/event_results_page.dart';
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

const _userId = 4242;
const _eventId = 1234;

List<Map<String, dynamic>> _results() => [
      {
        "u_name": "Me",
        "u_surname": "Runner",
        "r_uid": _userId,
        "r_time": 1004,
        "r_finish_pos": 1,
        "u_sex": "m",
      },
    ];

Run _run({RunType type = RunType.official}) => Run(
      eventId: type == RunType.selfie ? null : _eventId,
      date: DateTime(2024, 5, 4),
      time: "16:44",
      location: "Южен Парк",
      position: 80,
      pace: "03:20",
      speed: "17.93",
      runType: type,
      distance: 5000,
      totalTime: "16:44",
    );

/// URLs requested during the current test.
final List<Uri> requests = [];

/// Answers every HTTP request made inside [body] with the fake results.
Future<void> withFakeResults(Future<void> Function() body) {
  requests.clear();
  return http.runWithClient(
    body,
    () => MockClient((request) async {
      requests.add(request.url);
      return http.Response(jsonEncode(_results()), 200,
          headers: {"content-type": "application/json; charset=utf-8"});
    }),
  );
}

/// Shows the real Runs tab with [run]'s details page open.
Future<void> openRunDetails(WidgetTester tester, Run run,
    {Locale locale = const Locale('bg'),
    Size screen = const Size(412, 915)}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final authRes = AuthenticationResource();
  await authRes.authenticateWithUserId(_userId);
  final navigatorKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authRes),
      // Not loading, so the runs list doesn't show an endless spinner.
      ChangeNotifierProvider(create: (_) => RunsResource()..loading = false),
    ],
    child: localizedApp(
      TabNavigator(navigatorKey: navigatorKey, routes: runsTabRoutes),
      locale: locale,
    ),
  ));
  navigatorKey.currentState!.pushNamed("/run-details", arguments: run);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets("the button opens the run's event results", (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run());

      await tester.tap(find.text("Пълно класиране"));
      await tester.pumpAndSettle();

      expect(find.byType(EventResultsPage), findsOneWidget);
      // The details page also loads these results for its gauge.
      expect(requests.toSet(),
          {Uri.parse("${constants.resultEventsUrl}$_eventId")});
    });
  });

  testWidgets('back from the results returns to the run details',
      (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run());

      await tester.tap(find.text("Пълно класиране"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      expect(find.byType(EventResultsPage), findsNothing);
      expect(find.text("Пълно класиране"), findsOneWidget);
    });
  });

  testWidgets('the button can be reached in landscape', (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run(), screen: const Size(915, 412));

      await tester.ensureVisible(find.text("Пълно класиране"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Пълно класиране"));
      await tester.pumpAndSettle();

      expect(find.byType(EventResultsPage), findsOneWidget);
    });
  });

  testWidgets('the button is labelled in English', (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run(), locale: const Locale('en'));

      expect(find.text("Full results"), findsOneWidget);
    });
  });

  testWidgets('there is no button for a selfie run', (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run(type: RunType.selfie));

      expect(find.text("Пълно класиране"), findsNothing);
    });
  });

  testWidgets("an XL run opens its results from the XL endpoint",
      (tester) async {
    await withFakeResults(() async {
      await openRunDetails(tester, _run(type: RunType.xl));

      await tester.tap(find.text("Пълно класиране"));
      await tester.pumpAndSettle();

      expect(find.byType(EventResultsPage), findsOneWidget);
      expect(requests.toSet(),
          {Uri.parse("${constants.xlResultEventsUrl}$_eventId")});
    });
  });
}
