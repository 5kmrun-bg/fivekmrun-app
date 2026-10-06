import 'package:fivekmrun_flutter/offline_chart/details_tile.dart';
import 'package:fivekmrun_flutter/offline_chart/no_results_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../localized_app.dart';

void main() {
  group('NoResultsComponent', () {
    testWidgets('shows the "no suitable runs" message in Bulgarian',
        (tester) async {
      await tester.pumpWidget(localizedApp(const NoResultsComponent()));

      expect(find.text('Няма подходящи бягания!'), findsOneWidget);
    });

    testWidgets('shows the English text when the locale is English',
        (tester) async {
      await tester.pumpWidget(
          localizedApp(const NoResultsComponent(), locale: const Locale('en')));

      expect(find.text('No suitable runs!'), findsOneWidget);
      expect(find.textContaining('uploaded to Strava'), findsOneWidget);
    });
  });

  group('DetailsTile', () {
    testWidgets('renders the title and the value in the accent colour',
        (tester) async {
      await tester.pumpWidget(localizedApp(const DetailsTile(
          title: 'Distance', value: '5.02 km', accentColor: Colors.red)));

      expect(find.text('Distance'), findsOneWidget);
      final value = tester.widget<Text>(find.text('5.02 km'));
      expect(value.style?.color, Colors.red);
    });
  });
}
