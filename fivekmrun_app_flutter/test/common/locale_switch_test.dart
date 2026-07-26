import 'package:fivekmrun_flutter/common/locale_switch.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

Future<void> pumpSwitcher(WidgetTester tester) async {
  final provider = LocaleProvider();
  await tester.pumpWidget(localizedApp(
    ChangeNotifierProvider<LocaleProvider>.value(
      value: provider,
      child: const LocaleSwitcherWidget(),
    ),
  ));
  // Let the provider finish reading the saved preference.
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offers one entry per supported locale', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});

    await pumpSwitcher(tester);
    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();

    for (final locale in AppLocalizations.supportedLocales) {
      // Two per locale once the menu is open: the button's own child and the
      // menu item.
      expect(find.text(locale.toString().toUpperCase()), findsWidgets,
          reason: 'no entry for $locale');
    }
  });

  testWidgets('shows the active locale on the closed button', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});

    await pumpSwitcher(tester);

    expect(find.text('EN'), findsOneWidget);
    expect(find.text('BG'), findsNothing);
  });

  testWidgets('picking a locale switches the app language', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});

    await pumpSwitcher(tester);
    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN').last);
    await tester.pumpAndSettle();

    expect(find.text('EN'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'en');
  });
}
