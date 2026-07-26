import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/locale_provider.dart';
import 'package:provider/provider.dart';

class LocaleSwitcherWidget extends StatelessWidget {
  const LocaleSwitcherWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale;
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        padding: EdgeInsets.symmetric(horizontal: 10),
        value: locale,
        icon: Container(width: 12),
        items: AppLocalizations.supportedLocales.map(
              (nextLocale) {
            return DropdownMenuItem(
              value: nextLocale,
              child: Center(
                child: Text(nextLocale.toString().toUpperCase(),style: TextStyle(
                  color: nextLocale == locale ? Theme.of(context).colorScheme.secondary: Colors.grey,
                ),),

              ),
            );
          },
        ).toList(),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            provider.setLocale(newLocale);
          }
        },
      ),
    );
  }
}