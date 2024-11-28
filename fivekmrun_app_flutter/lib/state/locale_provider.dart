import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      Locale platformLocale = Locale(Platform.localeName);
      _locale = (AppLocalizations.supportedLocales.contains(platformLocale))
          ? platformLocale
          : Locale("en");
      await preferences.setString('locale', _locale!.languageCode);
    }
    notifyListeners();
  }

  Future<void> clearLocale() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('locale');
    _locale = null;
    notifyListeners();
  }
}
