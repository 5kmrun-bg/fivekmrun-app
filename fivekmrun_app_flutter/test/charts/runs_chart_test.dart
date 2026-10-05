import 'package:fivekmrun_flutter/charts/runs_chart.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Unlike the widget tests, which get translations by pumping their widget
// inside `localizedApp`, runsChartSelectionLabel is a plain function with no
// widget to render. lookupAppLocalizations (generated from the .arb files
// alongside AppLocalizations) returns the same strings for a given locale
// directly, without building a widget tree.
void main() {
  group('runsChartSelectionLabel', () {
    test('shows the date and the time with its unit in Bulgarian', () {
      final label = runsChartSelectionLabel(
          lookupAppLocalizations(const Locale('bg')),
          DateTime(2026, 1, 30),
          '29:17');

      expect(label, 'Дата: 30.01.2026\nВреме: 29:17 мин');
    });

    test('shows the date and the time with its unit in English', () {
      final label = runsChartSelectionLabel(
          lookupAppLocalizations(const Locale('en')),
          DateTime(2026, 1, 30),
          '29:17');

      expect(label, 'Date: 30.01.2026\nTime: 29:17 min');
    });
  });
}
