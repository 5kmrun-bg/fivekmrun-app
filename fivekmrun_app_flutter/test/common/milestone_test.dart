import 'package:fivekmrun_flutter/common/milestone.dart';
import 'package:fivekmrun_flutter/common/milestone_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The gauge draws a pie chart, so give it a fixed size to lay out in.
Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Center(child: SizedBox(width: 200, height: 200, child: child)),
    ),
  );
}

Color _gaugeColor(WidgetTester tester) =>
    tester.widget<MilestoneGauge>(find.byType(MilestoneGauge)).accentColor;

void main() {
  group('MilestoneGauge', () {
    testWidgets('shows the value and the milestone', (tester) async {
      await tester.pumpWidget(
          _app(const MilestoneGauge(37, 50, Colors.red, animate: false)));
      await tester.pumpAndSettle();

      expect(find.text('37'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('renders with a value of 0', (tester) async {
      await tester.pumpWidget(
          _app(const MilestoneGauge(0, 50, Colors.red, animate: false)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('MilestoneTile', () {
    testWidgets('shows the title', (tester) async {
      await tester.pumpWidget(_app(
          const MilestoneTile(value: 37, milestone: 50, title: 'Runs')));
      await tester.pump();

      expect(find.text('Runs'), findsOneWidget);
      expect(find.text('37'), findsOneWidget);
    });

    testWidgets('passes the runner-status colour to the gauge',
        (tester) async {
      await tester.pumpWidget(_app(
          const MilestoneTile(value: 120, milestone: 200, title: 'Runs')));
      await tester.pump();

      expect(_gaugeColor(tester), const Color.fromRGBO(202, 202, 202, 1));
    });

    testWidgets('uses the theme secondary colour below 50 runs',
        (tester) async {
      await tester.pumpWidget(_app(
        const MilestoneTile(value: 37, milestone: 50, title: 'Runs'),
        theme: ThemeData(
            colorScheme: const ColorScheme.dark(secondary: Colors.orange)),
      ));
      await tester.pump();

      expect(_gaugeColor(tester), Colors.orange);
    });
  });
}
