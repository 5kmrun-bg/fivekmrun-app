import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Wraps [child] in a `MaterialApp` carrying the app's localization
/// delegates, so widgets that call `AppLocalizations.of(context)!` work under
/// test. A bare `MaterialApp` has no `AppLocalizations` in its tree, and those
/// calls throw on the null.
///
/// [locale] defaults to Bulgarian — the app's default — so tests can assert on
/// the strings a Bulgarian user sees. Pass `Locale('en')` to check the
/// English translation of the same screen.
Widget localizedApp(Widget child, {Locale locale = const Locale('bg')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
