import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// A semver-ish `MAJOR.MINOR.PATCH` version, compared numerically rather than
/// as a string — "3.9.0" must sort below "3.18.0", which a string compare
/// gets wrong. Missing segments (e.g. a tag like "3.13") default to 0.
class SemVer implements Comparable<SemVer> {
  final int major;
  final int minor;
  final int patch;

  const SemVer(this.major, this.minor, this.patch);

  factory SemVer.parse(String version) {
    final parts = version.split('.');
    int segment(int index) =>
        index < parts.length ? (int.tryParse(parts[index]) ?? 0) : 0;
    return SemVer(segment(0), segment(1), segment(2));
  }

  @override
  int compareTo(SemVer other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }
}

/// One version's worth of highlight bullets, keyed by locale code (`"bg"`,
/// `"en"`).
class WhatsNewEntry {
  final String version;
  final Map<String, List<String>> bulletsByLocale;

  WhatsNewEntry({required this.version, required this.bulletsByLocale});

  /// Falls back to Bulgarian when the active locale has no bullets — bg is
  /// the primary language for 5kmRun's audience.
  List<String> bulletsFor(String localeCode) =>
      bulletsByLocale[localeCode] ?? bulletsByLocale['bg'] ?? const [];
}

/// Loads and resolves the bundled `assets/whats_new.json` release-highlights
/// archive.
///
/// Only significant, user-facing releases get an entry — patch and
/// tech-only releases are simply absent, by design (see `/release`).
class WhatsNewResource {
  List<WhatsNewEntry> _entries = const [];

  /// Newest first.
  List<WhatsNewEntry> get entries => _entries;

  /// Never throws: a missing or malformed asset must not crash startup, so a
  /// parse failure just leaves [entries] empty and the popup/screen skip
  /// silently.
  Future<void> load({AssetBundle? bundle}) async {
    try {
      final raw =
          await (bundle ?? rootBundle).loadString('assets/whats_new.json');
      final Map<String, dynamic> json = jsonDecode(raw);

      final versions = json.keys.toList()
        ..sort((a, b) => SemVer.parse(b).compareTo(SemVer.parse(a)));

      _entries = versions.map((version) {
        final Map<String, dynamic> localeMap = json[version];
        return WhatsNewEntry(
          version: version,
          bulletsByLocale: localeMap.map((locale, bullets) =>
              MapEntry(locale, List<String>.from(bullets))),
        );
      }).toList();
    } catch (_) {
      _entries = const [];
    }
  }

  WhatsNewEntry? entryFor(String version) =>
      _entries.firstWhereOrNull((e) => e.version == version);

  /// The history screen shows only the last three versions, per product
  /// decision — the archive otherwise grows unbounded release over release.
  List<WhatsNewEntry> get recentEntries => _entries.take(3).toList();
}
