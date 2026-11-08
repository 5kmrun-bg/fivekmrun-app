import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/profile.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('tapping a best time opens that run\'s details in the Runs tab',
      (tester) async {
    int? selectedTab;
    final tabHelper = TabNavigationHelper((index) => selectedTab = index);
    final run = Run(
      eventId: 1234,
      location: 'Южен Парк',
      date: DateTime(2024, 5, 4),
      timeInSeconds: 1004,
    );

    // The app's navigator stands in for the Runs tab's, like the RunCard
    // test, so the push lands on a stub details page we can inspect.
    await tester.pumpWidget(Provider<TabNavigationHelper>.value(
      value: tabHelper,
      child: MaterialApp(
        navigatorKey: tabHelper.navigatorKeys[AppTab.runs],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('bg'),
        routes: {
          '/run-details': (context) => Scaffold(
              body: Text(
                  'details for ${ModalRoute.of(context)!.settings.arguments == run}')),
        },
        home: Scaffold(body: BestTimesCard(runs: [run])),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(charts.BarChart));
    await tester.pumpAndSettle();

    expect(selectedTab, AppTab.runs.index);
    expect(find.text('details for true'), findsOneWidget);
  });
}
