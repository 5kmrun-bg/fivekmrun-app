import 'package:fivekmrun_flutter/common/profile_barcode_action.dart';
import 'package:fivekmrun_flutter/common/profile_header_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reproduces the profile header's outer row: a leading flex:3 slot for the
/// barcode icon, a flex:5 middle slot, and a trailing flex:3 slot for the
/// settings cog, matching lib/profile.dart's actual flex ratios.
Widget headerHarness({required double width}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: ProfileBarcodeAction(onPressed: () {}),
            ),
            const Expanded(flex: 5, child: SizedBox()),
            Expanded(
              flex: 3,
              child: ProfileHeaderActions(
                showWrapIcon: false,
                onSettings: () {},
                onWrapTap: () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'the barcode icon and the settings cog sit equally far from their edges',
    (tester) async {
      const width = 360.0;
      await tester.pumpWidget(headerHarness(width: width));

      final barcodeLeft = tester.getTopLeft(find.byType(IconButton).first).dx;
      final settingsRight =
          width - tester.getTopRight(find.byType(IconButton).last).dx;

      expect(barcodeLeft, closeTo(settingsRight, 0.5));
    },
  );
}
