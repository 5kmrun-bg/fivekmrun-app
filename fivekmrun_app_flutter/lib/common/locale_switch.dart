import 'package:flutter/material.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:provider/provider.dart';

/// Maps a supported locale to the flag asset representing it.
///
/// Only `bg` and `en` are supported, so this is a simple two-state toggle
/// rather than a dropdown. `en` shows the UK flag: 5kmRun's English speakers
/// are addressed generically, not specifically British ones, but `en_GB` is
/// the only English locale the app ships.
const Map<String, String> _flagAssetByLanguageCode = {
  'bg': 'assets/flag_bg.png',
  'en': 'assets/flag_gb.png',
};

/// Shows the currently active language's flag; tapping it switches to the
/// other supported locale immediately.
class LocaleSwitcherWidget extends StatelessWidget {
  const LocaleSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? defaultLocale;
    final asset = _flagAssetByLanguageCode[locale.languageCode] ??
        _flagAssetByLanguageCode[defaultLocale.languageCode]!;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.locale_switcher_semantics_label,
      child: GestureDetector(
        onTap: () {
          const supported = AppLocalizations.supportedLocales;
          final other = supported.firstWhere(
            (candidate) => candidate.languageCode != locale.languageCode,
            orElse: () => locale,
          );
          if (other.languageCode != locale.languageCode) {
            provider.setLocale(other);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.asset(
            asset,
            width: 32,
            height: 22,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
