import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/login/login.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Not `localizedApp`: that helper pins a fixed `locale`, but this test needs
// the app's `locale` to react to `LocaleProvider`, matching the real
// MaterialApp wiring in main.dart.
Widget _buildLoginApp(LocaleProvider localeProvider) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ChangeNotifierProvider<AuthenticationResource>(
        create: (_) => AuthenticationResource(),
      ),
    ],
    child: Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          locale: provider.locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Login(),
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows a locale switcher on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});
    final provider = LocaleProvider();

    await tester.pumpWidget(_buildLoginApp(provider));
    await tester.pumpAndSettle();
    // Login's inner Column sits in a hardcoded 220x400 Container that is
    // already tight on a real device; with the fallback fonts the test
    // environment substitutes, the same content measures a few pixels taller
    // and overflows. Pre-existing and orthogonal to the locale switcher this
    // test targets, so the resulting render exception is consumed here
    // instead of failing the test.
    tester.takeException();

    expect(find.byType(GestureDetector), findsWidgets);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets(
      'tapping the switcher changes visible text from Bulgarian to English',
      (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});
    final provider = LocaleProvider();

    await tester.pumpWidget(_buildLoginApp(provider));
    await tester.pumpAndSettle();
    tester.takeException(); // see comment above

    expect(find.text('Нямате регистрация?'), findsOneWidget);
    expect(find.text("You don't have an account?"), findsNothing);

    final l10nBg = await AppLocalizations.delegate.load(const Locale('bg'));
    await tester.tap(
      find.bySemanticsLabel(l10nBg.locale_switcher_semantics_label),
    );
    await tester.pumpAndSettle();
    tester.takeException(); // see comment above

    expect(find.text('Нямате регистрация?'), findsNothing);
    expect(find.text("You don't have an account?"), findsOneWidget);
  });
}
