import 'dart:convert';

import 'package:fivekmrun_flutter/timekeeping/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

Future<void> pumpScanner(WidgetTester tester) async {
  await tester.pumpWidget(
      localizedApp(const BarcodeScanner(), locale: const Locale('en')));
  // Lets _loadSavedState's SharedPreferences read land before interacting.
  await tester.pump(const Duration(milliseconds: 100));
}

Future<List<Map<String, dynamic>>> savedValues() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('barcode_scanner_values');
  if (json == null) return [];
  return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
}

void main() {
  testWidgets('manual add appends a valid pair to an empty list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpScanner(tester);

    await tester.tap(find.byTooltip('Add manually'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).at(0), '12345');
    await tester.enterText(find.byType(TextField).at(1), '017');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('0000012345'), findsOneWidget);
    expect(find.textContaining('J017'), findsOneWidget);

    final saved = await savedValues();
    expect(saved, hasLength(2));
    expect(saved[0]['value'], '0000012345');
    expect(saved[0]['isManual'], isTrue);
    expect(saved[1]['value'], 'J017');
    expect(saved[1]['isManual'], isTrue);
  });

  testWidgets('invalid input is rejected without mutating the list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpScanner(tester);

    await tester.tap(find.byTooltip('Add manually'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Both fields left empty.
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(
        find.text('Enter a valid runner ID (up to 10 digits)'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Scan a barcode'), findsOneWidget);
    expect(await savedValues(), isEmpty);
  });

  testWidgets(
      'an odd-length list completes the dangling pair instead of '
      'appending a new one', (tester) async {
    SharedPreferences.setMockInitialValues({
      'barcode_scanner_values': jsonEncode([
        ScannedBarcode(value: '0000012345', timestamp: DateTime(2026, 1, 1))
            .toJson(),
      ]),
    });
    await pumpScanner(tester);

    await tester.tap(find.byTooltip('Add manually'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The runner ID field is locked and pre-filled — only the place is
    // editable to complete the pair.
    final runnerIdField =
        tester.widget<TextField>(find.byType(TextField).at(0));
    expect(runnerIdField.enabled, isFalse);
    expect(runnerIdField.controller!.text, '12345');

    await tester.enterText(find.byType(TextField).at(1), '099');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final saved = await savedValues();
    expect(saved, hasLength(2)); // completed, not a fresh 3rd/4th entry
    expect(saved[0]['value'], '0000012345');
    expect(saved[1]['value'], 'J099');
    expect(saved[1]['isManual'], isTrue);
    expect(find.textContaining('J099'), findsOneWidget);
  });

  testWidgets(
      'editing an existing pair updates values in place and '
      'preserves the original timestamps', (tester) async {
    final runnerTimestamp = DateTime(2026, 1, 1, 10, 0);
    final placeTimestamp = DateTime(2026, 1, 1, 10, 5);
    SharedPreferences.setMockInitialValues({
      'barcode_scanner_values': jsonEncode([
        ScannedBarcode(value: '0000012345', timestamp: runnerTimestamp)
            .toJson(),
        ScannedBarcode(value: 'J001', timestamp: placeTimestamp).toJson(),
      ]),
    });
    await pumpScanner(tester);

    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final runnerIdField =
        tester.widget<TextField>(find.byType(TextField).at(0));
    final placeField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(runnerIdField.enabled, isTrue);
    expect(runnerIdField.controller!.text, '12345');
    expect(placeField.controller!.text, '001');

    await tester.enterText(find.byType(TextField).at(0), '99999');
    await tester.enterText(find.byType(TextField).at(1), '005');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final saved = await savedValues();
    expect(saved, hasLength(2));
    expect(saved[0]['value'], '0000099999');
    expect(saved[0]['timestamp'], runnerTimestamp.toIso8601String());
    expect(saved[0]['isManual'], isTrue);
    expect(saved[1]['value'], 'J005');
    expect(saved[1]['timestamp'], placeTimestamp.toIso8601String());
    expect(saved[1]['isManual'], isTrue);
  });

  testWidgets('manually added or edited rows are marked with a badge icon',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'barcode_scanner_values': jsonEncode([
        ScannedBarcode(value: '0000012345', timestamp: DateTime(2026, 1, 1))
            .toJson(),
        ScannedBarcode(value: 'J001', timestamp: DateTime(2026, 1, 1)).toJson(),
      ]),
    });
    await pumpScanner(tester);

    expect(find.byIcon(Icons.edit), findsNothing);

    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Save')); // unchanged values still validate
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets(
      'swipe-to-delete still removes a manually added pair, and pair '
      'numbering stays correct afterwards', (tester) async {
    SharedPreferences.setMockInitialValues({
      'barcode_scanner_values': jsonEncode([
        ScannedBarcode(
                value: '0000011111',
                timestamp: DateTime(2026, 1, 1),
                isManual: true)
            .toJson(),
        ScannedBarcode(
                value: 'J001', timestamp: DateTime(2026, 1, 1), isManual: true)
            .toJson(),
        ScannedBarcode(value: '0000022222', timestamp: DateTime(2026, 1, 2))
            .toJson(),
        ScannedBarcode(value: 'J002', timestamp: DateTime(2026, 1, 2)).toJson(),
      ]),
    });
    await pumpScanner(tester);

    // Newest pair (0000022222 / J002) renders first, numbered 2; the manual
    // pair (0000011111 / J001) renders second, numbered 1.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.drag(find.byType(ListTile).last, const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final saved = await savedValues();
    expect(saved, hasLength(2));
    expect(saved[0]['value'], '0000022222');
    // Only one pair left, renumbered to 1.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
  });
}
