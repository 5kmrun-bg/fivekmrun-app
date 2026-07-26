import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Used when neither a saved preference nor the device locale names a
/// language the app ships translations for.
const Locale fallbackLocale = Locale("bg");

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
      Locale platformLocale = _getLocale(Platform.localeName);

      _locale = (AppLocalizations.supportedLocales.contains(platformLocale))
          ? platformLocale
          : fallbackLocale;
      await preferences.setString('locale', _locale!.languageCode);
    }
    notifyListeners();
  }

  Locale _getLocale(String localeString) {
    if (localeString.contains('_') || localeString.contains('-')) {
      var parts = localeString.split(RegExp(r'[_-]'));
      return Locale(parts.first);
    } else {
      return Locale(localeString);
    }
  }
}
