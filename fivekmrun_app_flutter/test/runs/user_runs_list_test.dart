import 'package:fivekmrun_flutter/runs/user_runs_page.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../localized_app.dart';

Run officialRun() => Run(
      date: DateTime(2021, 1, 2),
      time: "22:15",
      timeInSeconds: 1335,
      location: "Южен парк",
      position: 3,
    );

void main() {
  testWidgets('run time carries the Bulgarian minutes unit', (tester) async {
    await tester.pumpWidget(localizedApp(UserRunsList(runs: [officialRun()])));

    expect(find.text('22:15 мин'), findsOneWidget);
  });

  testWidgets('run time carries the English minutes unit', (tester) async {
    await tester.pumpWidget(localizedApp(
      UserRunsList(runs: [officialRun()]),
      locale: const Locale('en'),
    ));

    expect(find.text('22:15 min'), findsOneWidget);
    expect(find.text('22:15 мин'), findsNothing);
  });
}
