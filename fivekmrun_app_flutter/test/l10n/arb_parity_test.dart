import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the rule in CLAUDE.md that `app_bg.arb` and `app_en.arb` stay in
/// sync. A key added to only one file silently falls back to the template
/// language at runtime, which is easy to miss in review.
void main() {
  late Map<String, dynamic> bg;
  late Map<String, dynamic> en;

  setUpAll(() {
    bg = jsonDecode(File('lib/l10n/app_bg.arb').readAsStringSync())
        as Map<String, dynamic>;
    en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
  });

  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  test('every Bulgarian message has an English translation', () {
    expect(messageKeys(bg).difference(messageKeys(en)), isEmpty,
        reason: 'keys present in app_bg.arb but missing from app_en.arb');
  });

  test('English has no messages the template is missing', () {
    expect(messageKeys(en).difference(messageKeys(bg)), isEmpty,
        reason: 'keys present in app_en.arb but missing from app_bg.arb');
  });

  test('no message is left empty in either locale', () {
    for (final arb in <MapEntry<String, Map<String, dynamic>>>[
      MapEntry('app_bg.arb', bg),
      MapEntry('app_en.arb', en),
    ]) {
      for (final key in messageKeys(arb.value)) {
        expect((arb.value[key] as String).trim(), isNotEmpty,
            reason: '${arb.key}: "$key" is empty');
      }
    }
  });

  test('placeholders match between the two locales', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    Set<String> placeholdersIn(String message) =>
        placeholder.allMatches(message).map((m) => m.group(1)!).toSet();

    for (final key in messageKeys(bg)) {
      expect(
          placeholdersIn(en[key] as String), placeholdersIn(bg[key] as String),
          reason: '"$key" uses different placeholders in bg and en');
    }
  });
}
