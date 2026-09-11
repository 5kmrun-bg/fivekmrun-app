import 'package:fivekmrun_flutter/common/profile_barcode_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileBarcodeAction', () {
    Widget harness({required VoidCallback onPressed}) {
      return MaterialApp(
        home: Scaffold(
          body: ProfileBarcodeAction(onPressed: onPressed),
        ),
      );
    }

    testWidgets('is left-aligned so the icon hugs the leading edge', (
      tester,
    ) async {
      await tester.pumpWidget(harness(onPressed: () {}));

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.start);
    });

    testWidgets('tapping the icon calls onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(harness(onPressed: () => tapped = true));

      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });
  });
}
