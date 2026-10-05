import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/offline_chart/add_offline_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Unlike the widget tests, which get translations by pumping their widget
// inside `localizedApp`, stravaActivityTimesLabel is a plain function with no
// widget to render. lookupAppLocalizations (generated from the .arb files
// alongside AppLocalizations) returns the same strings for a given locale
// directly, without building a widget tree.
void main() {
  group('stravaActivityTimesLabel', () {
    test('shows the fastest 5 km and total time with the unit in Bulgarian',
        () {
      final label = stravaActivityTimesLabel(
          lookupAppLocalizations(const Locale('bg')), '24:10', '31:45');

      expect(label, '24:10 / 31:45 мин');
    });

    test('shows the fastest 5 km and total time with the unit in English', () {
      final label = stravaActivityTimesLabel(
          lookupAppLocalizations(const Locale('en')), '24:10', '31:45');

      expect(label, '24:10 / 31:45 min');
    });
  });
}
