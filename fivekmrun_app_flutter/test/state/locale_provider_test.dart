import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the microtasks the provider's async constructor work is queued on.
/// `LocaleProvider()` kicks off `_loadLocale()` without exposing the future,
/// so tests have to wait for the event loop rather than await it.
Future<LocaleProvider> loadedProvider() async {
  final provider = LocaleProvider();
  await Future<void>.delayed(Duration.zero);
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores a saved supported locale', () async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});

    final provider = await loadedProvider();

    expect(provider.locale, const Locale('en'));
  });

  test('ignores a saved locale the app has no translations for', () async {
    // A code left behind by an older build, or hand-edited, must not reach
    // the settings dropdown — it asserts when its value matches no item.
    SharedPreferences.setMockInitialValues({'locale': 'de'});

    final provider = await loadedProvider();

    expect(provider.locale, defaultLocale);
  });

  test('defaults to Bulgarian when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});

    final provider = await loadedProvider();

    expect(provider.locale, const Locale('bg'));
  });

  test('the default ignores the device locale', () async {
    // The host running these tests is en_US (see Platform.localeName), so a
    // device-matching implementation would resolve to English here. 5kmRun's
    // members largely run English phones, and the app should still open in
    // Bulgarian for them.
    SharedPreferences.setMockInitialValues({});

    final provider = await loadedProvider();

    expect(provider.locale, isNot(const Locale('en')));
  });

  test('persists the default so it is stable across launches', () async {
    SharedPreferences.setMockInitialValues({});

    final provider = await loadedProvider();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getString('locale'), provider.locale!.languageCode);
  });

  test('setLocale persists the choice and notifies listeners', () async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});
    final provider = await loadedProvider();

    var notifications = 0;
    provider.addListener(() => notifications++);

    await provider.setLocale(const Locale('en'));

    expect(provider.locale, const Locale('en'));
    expect(notifications, 1);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'en');
  });

  test('the default locale is one the app actually ships', () {
    expect(AppLocalizations.supportedLocales, contains(defaultLocale));
  });
}
