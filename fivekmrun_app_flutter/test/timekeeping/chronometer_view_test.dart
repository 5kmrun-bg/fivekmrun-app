import 'package:fivekmrun_flutter/timekeeping/chronometer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

Widget _harness() =>
    localizedApp(const ChronometerView(), locale: const Locale('en'));

// ElevatedButton.icon returns a private `_ElevatedButtonWithIcon` subtype, so
// `find.widgetWithText(ElevatedButton, ...)`'s exact-type match misses it —
// tap each icon-button's (unique) icon instead, which also disambiguates the
// main Reset button from the confirm dialog's "Reset" TextButton (same
// label, no icon).
Finder _startStopButton() => find.byIcon(Icons.play_arrow);
Finder _stopButton() => find.byIcon(Icons.stop);
Finder _lapButton() => find.byIcon(Icons.flag);
Finder _mainResetButton() => find.byIcon(Icons.refresh);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('initial state', () {
    testWidgets('shows 00:00.00 and no laps recorded', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('00:00.00'), findsOneWidget);
      expect(find.text('No laps recorded'), findsOneWidget);
      expect(_startStopButton(), findsOneWidget);
    });

    testWidgets('lap button does nothing while stopped', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_lapButton());
      await tester.pumpAndSettle();

      expect(find.text('No laps recorded'), findsOneWidget);
    });
  });

  group('start/stop', () {
    testWidgets('tapping Start flips the button to Stop, and back on Stop',
        (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_startStopButton());
      await tester.pump();

      expect(_stopButton(), findsOneWidget);
      expect(_startStopButton(), findsNothing);

      await tester.tap(_stopButton());
      await tester.pump();

      expect(_startStopButton(), findsOneWidget);
    });

    testWidgets('pausing persists the elapsed time and drops the start marker',
        (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_startStopButton());
      await tester.pump();
      await tester.tap(_stopButton());
      await tester.pump();

      final prefs = await SharedPreferences.getInstance();
      // The exact value is real elapsed wall-clock time between the two taps
      // (DateTime.now()-based, not virtualised by the test clock) — assert
      // it was recorded as a small non-negative duration rather than pin an
      // exact figure.
      expect(prefs.getInt('chronometer_paused_at'), greaterThanOrEqualTo(0));
      expect(prefs.containsKey('chronometer_start_time'), isFalse);
    });
  });

  group('marking a lap', () {
    testWidgets('adds an entry to the list while running', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_startStopButton());
      await tester.pump();
      await tester.tap(_lapButton());
      await tester.pumpAndSettle();

      expect(find.text('No laps recorded'), findsNothing);
      expect(find.textContaining('Total time:'), findsOneWidget);
    });
  });

  group('formatting a restored paused time', () {
    testWidgets('renders minutes:seconds.hundredths, zero-padded',
        (tester) async {
      SharedPreferences.setMockInitialValues(
          <String, Object>{'chronometer_paused_at': 4500});

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('00:04.50'), findsOneWidget);
      expect(_startStopButton(), findsOneWidget);
    });

    testWidgets('adds an hours segment once elapsed time passes an hour',
        (tester) async {
      // 1h 1m 1.234s -> hours=1, minutes=1, seconds=1, hundredths=23.
      SharedPreferences.setMockInitialValues(
          <String, Object>{'chronometer_paused_at': 3661234});

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('01:01:01.23'), findsOneWidget);
    });
  });

  group('restored laps list', () {
    testWidgets('shows the newest lap first, with correct split and total',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chronometer_paused_at': 2500,
        'chronometer_laps': '[1000,2500]',
      });

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Lap 2 (newest, listed first): total 2500ms, split from lap 1 = 1500ms.
      expect(find.textContaining('Total time: 00:02.50'), findsOneWidget);
      expect(find.textContaining('Lap: 00:01.50'), findsOneWidget);
      // Lap 1: total 1000ms, split from start = 1000ms.
      expect(find.textContaining('Total time: 00:01.00'), findsOneWidget);
      expect(find.textContaining('Lap: 00:01.00'), findsOneWidget);
    });

    testWidgets('deleting a lap asks for confirmation and honours cancel',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chronometer_paused_at': 1000,
        'chronometer_laps': '[1000]',
      });

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(const Key('lap_0')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete lap'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('No laps recorded'), findsNothing);
      expect(find.textContaining('Total time: 00:01.00'), findsOneWidget);
    });

    testWidgets('deleting a lap removes it once confirmed', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chronometer_paused_at': 1000,
        'chronometer_laps': '[1000]',
      });

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(const Key('lap_0')), const Offset(-500, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('No laps recorded'), findsOneWidget);
    });
  });

  group('reset', () {
    testWidgets('asks for confirmation and honours cancel', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chronometer_paused_at': 1000,
        'chronometer_laps': '[1000]',
      });

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_mainResetButton());
      await tester.pumpAndSettle();

      expect(find.text('Reset timer'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('00:01.00'), findsOneWidget);
      expect(find.textContaining('Total time:'), findsOneWidget);
    });

    testWidgets('clears the elapsed time and laps once confirmed',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chronometer_paused_at': 1000,
        'chronometer_laps': '[1000]',
      });

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_mainResetButton());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();

      expect(find.text('00:00.00'), findsOneWidget);
      expect(find.text('No laps recorded'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('chronometer_start_time'), isFalse);
    });
  });

  group('export', () {
    testWidgets('shows a snackbar instead of sharing when there are no laps',
        (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save_alt));
      await tester.pump();

      expect(find.text('No laps to export'), findsOneWidget);
    });
  });

  group('restoring saved state', () {
    testWidgets('resumes a running timer already ahead of its start time',
        (tester) async {
      final startTime = DateTime.now().millisecondsSinceEpoch - 3000;
      SharedPreferences.setMockInitialValues(
          <String, Object>{'chronometer_start_time': startTime});

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // A running timer resumes showing Stop, with a non-zero elapsed time
      // computed from the saved start marker.
      expect(_stopButton(), findsOneWidget);
      expect(find.text('00:00.00'), findsNothing);

      await tester.tap(_stopButton());
      await tester.pump();

      expect(_startStopButton(), findsOneWidget);
    });
  });
}
