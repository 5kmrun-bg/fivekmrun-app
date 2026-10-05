import 'package:fivekmrun_flutter/common/run_card.dart';
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../localized_app.dart';

Run _run() => Run(
      date: DateTime(2026, 9, 26),
      position: 42,
      time: '22:30',
      pace: '04:30',
    );

void main() {
  group('RunCard', () {
    testWidgets('shows the title, position and date', (tester) async {
      await tester.pumpWidget(localizedApp(RunCard(run: _run(), title: 'Last run')));

      expect(find.text('Last run'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text(_run().displayDate), findsOneWidget);
    });

    testWidgets('shows the pace and time with their units in Bulgarian',
        (tester) async {
      await tester.pumpWidget(localizedApp(RunCard(run: _run(), title: 'Last run')));

      expect(find.text('04:30 мин/км'), findsOneWidget);
      expect(find.text('22:30 мин'), findsOneWidget);
    });

    testWidgets('shows the pace and time with their units in English',
        (tester) async {
      await tester.pumpWidget(localizedApp(RunCard(run: _run(), title: 'Last run'),
          locale: const Locale('en')));

      expect(find.text('04:30 min/km'), findsOneWidget);
      expect(find.text('22:30 min'), findsOneWidget);
    });

    testWidgets('tapping opens the run details in the Runs tab',
        (tester) async {
      int? selectedTab;
      final tabHelper = TabNavigationHelper((index) => selectedTab = index);
      final run = _run();

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
          routes: {
            '/run-details': (context) => Scaffold(
                body: Text(
                    'details for ${ModalRoute.of(context)!.settings.arguments == run}')),
          },
          home: Scaffold(body: RunCard(run: run, title: 'Last run')),
        ),
      ));

      await tester.tap(find.byType(RunCard));
      await tester.pumpAndSettle();

      expect(selectedTab, AppTab.runs.index);
      expect(find.text('details for true'), findsOneWidget);
    });
  });
}
