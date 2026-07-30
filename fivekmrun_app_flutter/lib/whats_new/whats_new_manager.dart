import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/whats_new_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_sheet.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Decides whether to show the "what's new" popup on this launch, and shows
/// it if so. Hooked into `home.dart`'s `afterFirstLayout`, ahead of
/// [AppRatingManager] — see the caller for how the two are sequenced so they
/// never appear at once.
class WhatsNewManager {
  /// Null unless injected for a test — production always builds and loads
  /// its own, but a test needs to control what the asset resolves to, and
  /// re-loading it here (with the real asset bundle) would clobber that.
  final WhatsNewResource? _resource;
  final Future<PackageInfo> Function() _packageInfoProvider;
  final LocalStorageResource _localStorage;

  WhatsNewManager({
    required LocalStorageResource localStorage,
    WhatsNewResource? resource,
    Future<PackageInfo> Function()? packageInfoProvider,
  })  : _localStorage = localStorage,
        _resource = resource,
        _packageInfoProvider = packageInfoProvider ?? PackageInfo.fromPlatform;

  /// Returns whether the popup was shown, so the caller can skip the rating
  /// prompt this launch rather than stacking it behind this one.
  Future<bool> maybeShowPopup(BuildContext context) async {
    final currentVersion = (await _packageInfoProvider()).version;
    final storedVersion = await _localStorage.lastSeenWhatsNewVersion;

    if (storedVersion == null) {
      // Fresh install: nothing is "new" to a first-time user.
      await _localStorage.setLastSeenWhatsNewVersion(currentVersion);
      return false;
    }

    final current = SemVer.parse(currentVersion);
    final stored = SemVer.parse(storedVersion);

    // Same version relaunch, or a downgrade/debug build — never show.
    if (current.compareTo(stored) <= 0) {
      return false;
    }

    final resource = _resource ?? WhatsNewResource();
    if (_resource == null) {
      await resource.load();
    }
    final entry = resource.entryFor(currentVersion);

    // Advance the stored version regardless of whether this version has an
    // entry, so a patch/tech-only release doesn't leave the user stuck being
    // prompted once a later version does have one.
    await _localStorage.setLastSeenWhatsNewVersion(currentVersion);

    if (entry == null) return false;
    if (!context.mounted) return false;

    final localeCode = Localizations.localeOf(context).languageCode;
    // Not awaited: the sheet's own future only resolves once the user
    // dismisses it, and this method's caller (afterFirstLayout) just needs
    // to know the popup was shown, not wait for it to close.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => WhatsNewSheet(
        version: currentVersion,
        bullets: entry.bulletsFor(localeCode),
      ),
    );

    return true;
  }
}
