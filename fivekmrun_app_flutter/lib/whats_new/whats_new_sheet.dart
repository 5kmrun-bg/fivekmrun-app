import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Bottom sheet shown once after an update, listing only the new version's
/// highlights — a dialog would match the existing rating prompt, but a sheet
/// handles longer bullet lists more gracefully (product decision on #199).
class WhatsNewSheet extends StatelessWidget {
  final String version;
  final List<String> bullets;

  const WhatsNewSheet({Key? key, required this.version, required this.bullets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.whats_new_sheet_title(version),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final bullet in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("• $bullet"),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.whats_new_sheet_dismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
