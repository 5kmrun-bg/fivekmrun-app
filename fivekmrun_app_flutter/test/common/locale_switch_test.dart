import 'package:fivekmrun_flutter/common/locale_switch.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localized_app.dart';

Future<LocaleProvider> pumpSwitcher(WidgetTester tester) async {
  final provider = LocaleProvider();
  await tester.pumpWidget(localizedApp(
    ChangeNotifierProvider<LocaleProvider>.value(
      value: provider,
      child: const LocaleSwitcherWidget(),
    ),
  ));
  // Let the provider finish reading the saved preference.
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the Bulgarian flag when the active locale is bg',
      (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});

    await pumpSwitcher(tester);

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/flag_bg.png');
  });

  testWidgets('shows the UK flag when the active locale is en',
      (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});

    await pumpSwitcher(tester);

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/flag_gb.png');
  });

  testWidgets('tapping the flag switches to the other supported locale',
      (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});

    final provider = await pumpSwitcher(tester);

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(provider.locale, const Locale('en'));

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/flag_gb.png');

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('locale'), 'en');
  });

  testWidgets('tapping again toggles back to Bulgarian', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});

    final provider = await pumpSwitcher(tester);

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(provider.locale, const Locale('bg'));
  });

  testWidgets('exposes a semantics label for accessibility', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'bg'});

    await pumpSwitcher(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('bg'));
    expect(
      find.bySemanticsLabel(l10n.locale_switcher_semantics_label),
      findsOneWidget,
    );
  });
}
