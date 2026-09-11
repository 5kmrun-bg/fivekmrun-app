import 'package:fivekmrun_flutter/common/profile_header_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWrapSeasonActive', () {
    test('true in the last two weeks of December', () {
      expect(isWrapSeasonActive(DateTime(2025, 12, 15)), isTrue);
      expect(isWrapSeasonActive(DateTime(2025, 12, 31)), isTrue);
    });

    test('false before December 15', () {
      expect(isWrapSeasonActive(DateTime(2025, 12, 14)), isFalse);
    });

    test('true throughout January', () {
      expect(isWrapSeasonActive(DateTime(2026, 1, 1)), isTrue);
      expect(isWrapSeasonActive(DateTime(2026, 1, 31)), isTrue);
    });

    test('false in other months', () {
      expect(isWrapSeasonActive(DateTime(2026, 2, 1)), isFalse);
      expect(isWrapSeasonActive(DateTime(2026, 6, 15)), isFalse);
    });
  });

  group('ProfileHeaderActions', () {
    Widget harness({required bool showWrapIcon}) {
      return MaterialApp(
        home: Scaffold(
          body: ProfileHeaderActions(
            showWrapIcon: showWrapIcon,
            onSettings: () {},
            onWrapTap: () {},
          ),
        ),
      );
    }

    testWidgets('is right-aligned so the cog hugs the trailing edge', (
      tester,
    ) async {
      await tester.pumpWidget(harness(showWrapIcon: false));

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });

    testWidgets('hides the wrap icon outside the wrap season', (tester) async {
      await tester.pumpWidget(harness(showWrapIcon: false));

      expect(find.byIcon(Icons.redeem), findsNothing);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets(
      'shows the wrap icon to the left of the cog during the wrap season',
      (tester) async {
        await tester.pumpWidget(harness(showWrapIcon: true));

        expect(find.byIcon(Icons.redeem), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);

        final redeemX = tester.getCenter(find.byIcon(Icons.redeem)).dx;
        final settingsX = tester.getCenter(find.byIcon(Icons.settings)).dx;
        expect(redeemX, lessThan(settingsX));
      },
    );

    testWidgets('tapping the cog calls onSettings', (tester) async {
      var settingsTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderActions(
              showWrapIcon: false,
              onSettings: () => settingsTapped = true,
              onWrapTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings));
      expect(settingsTapped, isTrue);
    });
  });
}
