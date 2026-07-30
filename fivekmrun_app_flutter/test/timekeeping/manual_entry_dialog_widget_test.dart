import 'dart:async';

import 'package:fivekmrun_flutter/timekeeping/manual_entry_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../localized_app.dart';

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(localizedApp(
      Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      }),
      locale: const Locale('en'),
    ));
    return captured;
  }

  Future<ManualEntryResult?> openDialog(
    WidgetTester tester,
    BuildContext context, {
    String? initialRunnerIdDigits,
    String? initialPlaceDigits,
    bool lockRunnerId = false,
    bool Function(String)? isDuplicateRunner,
  }) {
    final future = showDialog<ManualEntryResult>(
      context: context,
      builder: (context) => ManualEntryDialog(
        initialRunnerIdDigits: initialRunnerIdDigits,
        initialPlaceDigits: initialPlaceDigits,
        lockRunnerId: lockRunnerId,
        isDuplicateRunner: isDuplicateRunner ?? (_) => false,
      ),
    );
    return future;
  }

  testWidgets('submitting valid input returns the formatted pair',
      (tester) async {
    final context = await pumpContext(tester);
    final resultFuture = openDialog(tester, context);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '12345');
    await tester.enterText(find.byType(TextField).at(1), '017');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final result = await resultFuture;
    expect(result, isNotNull);
    expect(result!.runnerId, '0000012345');
    expect(result.place, 'J017');
  });

  testWidgets('invalid input shows an inline error and keeps the dialog open',
      (tester) async {
    final context = await pumpContext(tester);
    final resultFuture = openDialog(tester, context);
    await tester.pumpAndSettle();

    // Leave both fields empty and try to submit.
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
        find.text('Enter a valid runner ID (up to 10 digits)'), findsOneWidget);
    expect(find.text('Enter a valid place'), findsOneWidget);
    // The dialog is still open — Save is still there to tap.
    expect(find.text('Save'), findsOneWidget);

    // Now fill in valid values and confirm it closes.
    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNotNull);
  });

  testWidgets('cancel returns null without validating', (tester) async {
    final context = await pumpContext(tester);
    final resultFuture = openDialog(tester, context);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNull);
  });

  testWidgets(
      'runner ID field is locked and pre-filled when completing a '
      'dangling pair', (tester) async {
    final context = await pumpContext(tester);
    final resultFuture = openDialog(
      tester,
      context,
      initialRunnerIdDigits: '12345',
      lockRunnerId: true,
    );
    await tester.pumpAndSettle();

    final runnerIdField =
        tester.widget<TextField>(find.byType(TextField).at(0));
    expect(runnerIdField.enabled, isFalse);
    expect(runnerIdField.controller!.text, '12345');

    await tester.enterText(find.byType(TextField).at(1), '017');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final result = await resultFuture;
    expect(result!.runnerId, isNull);
    expect(result.place, 'J017');
  });

  testWidgets('editing pre-fills both fields', (tester) async {
    final context = await pumpContext(tester);
    unawaited(openDialog(
      tester,
      context,
      initialRunnerIdDigits: '12345',
      initialPlaceDigits: '017',
    ));
    await tester.pumpAndSettle();

    final runnerIdField =
        tester.widget<TextField>(find.byType(TextField).at(0));
    final placeField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(runnerIdField.enabled, isTrue);
    expect(runnerIdField.controller!.text, '12345');
    expect(placeField.controller!.text, '017');
  });

  testWidgets('shows a non-blocking duplicate warning but still allows submit',
      (tester) async {
    final context = await pumpContext(tester);
    final resultFuture = openDialog(
      tester,
      context,
      isDuplicateRunner: (id) => id == '0000012345',
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '12345');
    await tester.enterText(find.byType(TextField).at(1), '017');
    await tester.pump();

    expect(find.text('This runner ID is already recorded'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNotNull);
  });

  testWidgets('shows a live preview of the formatted values as they type',
      (tester) async {
    final context = await pumpContext(tester);
    unawaited(openDialog(tester, context));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.pump();

    expect(find.text('0000000005'), findsOneWidget);
    expect(find.text('J1'), findsOneWidget);
  });
}
