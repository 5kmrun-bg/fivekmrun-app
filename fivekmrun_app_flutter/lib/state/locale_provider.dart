import 'package:flutter/material.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language the app starts in until the user picks another one in
/// Settings.
///
/// Deliberately not derived from the device locale: 5kmRun is a Bulgarian
/// club, and most of its members run phones set to English, so matching the
/// device would open the app in English for people who never asked for it.
/// English is opt-in through the switcher.
const Locale defaultLocale = Locale("bg");

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final localeCode = preferences.getString('locale');

    // An unsupported code must never reach the UI: the settings dropdown
    // matches its value against supportedLocales and asserts on a value with
    // no matching item, so a stale or hand-edited preference would crash it.
    if (localeCode != null &&
        AppLocalizations.supportedLocales.contains(Locale(localeCode))) {
      _locale = Locale(localeCode);
    } else {
      _locale = defaultLocale;
      await preferences.setString('locale', _locale!.languageCode);
    }
    notifyListeners();
  }
}
