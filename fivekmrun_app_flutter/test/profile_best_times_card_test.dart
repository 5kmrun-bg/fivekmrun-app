import 'package:fivekmrun_flutter/events/event_results_page.dart';
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localized_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // The card is pumped as the root of the Profile tab's real route table, so
  // the test fails if the card stops navigating or the tab stops registering
  // the results page. The dashboard itself is swapped out: it needs the whole
  // app's providers, and the card is the only part under test.
  Future<void> pumpProfileTab(WidgetTester tester, List<Run> runs) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthenticationResource>(
      create: (_) => AuthenticationResource(),
      child: localizedApp(TabNavigator(
        navigatorKey: GlobalKey<NavigatorState>(),
        routes: {
          ...profileTabRoutes,
          '/': (_) => BestTimesCard(runs: runs),
        },
      )),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapBar(WidgetTester tester) async {
    await tester.tap(find.byType(charts.BarChart));
    // Let the page transition finish; the results request never settles
    // under test, so pumpAndSettle would spin on its progress indicator.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('tapping a best time opens that event\'s full results',
      (tester) async {
    await pumpProfileTab(tester, [
      Run(
        eventId: 1234,
        location: 'Южен Парк',
        date: DateTime(2024, 5, 4),
        timeInSeconds: 1004,
      ),
    ]);

    await tapBar(tester);

    final page = find.byType(EventResultsPage);
    expect(page, findsOneWidget);
    final event =
        ModalRoute.of(tester.element(page))!.settings.arguments as Event;
    expect(event.id, 1234);
  });

  testWidgets('a best time without an event id stays on the profile',
      (tester) async {
    await pumpProfileTab(tester, [
      Run(
        location: 'Южен Парк',
        date: DateTime(2024, 5, 4),
        timeInSeconds: 1004,
      ),
    ]);

    await tapBar(tester);

    expect(find.byType(EventResultsPage), findsNothing);
    expect(find.byType(BestTimesCard), findsOneWidget);
  });
}
