import 'package:fivekmrun_flutter/state/whats_new_resource.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final String? _content;

  _FakeAssetBundle(this._content);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final content = _content;
    if (content == null) throw Exception('asset not found: $key');
    return content;
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  group('SemVer', () {
    test('compares numerically, not lexicographically', () {
      expect(
          SemVer.parse('3.9.0').compareTo(SemVer.parse('3.18.0')), lessThan(0));
      expect(SemVer.parse('3.18.0').compareTo(SemVer.parse('3.9.0')),
          greaterThan(0));
    });

    test('treats missing segments as zero', () {
      expect(SemVer.parse('3.13').compareTo(SemVer.parse('3.13.0')), 0);
    });

    test('equal versions compare as 0', () {
      expect(SemVer.parse('3.18.0').compareTo(SemVer.parse('3.18.0')), 0);
    });
  });

  group('WhatsNewResource.load', () {
    test('parses entries newest-first by semver, not string order', () async {
      final resource = WhatsNewResource();
      await resource.load(bundle: _FakeAssetBundle('''
      {
        "3.9.0": {"bg": ["old"], "en": ["old"]},
        "3.18.0": {"bg": ["new"], "en": ["new"]}
      }
      '''));

      expect(resource.entries.map((e) => e.version), ['3.18.0', '3.9.0']);
    });

    test('bulletsFor falls back to bg when the locale is missing', () async {
      final resource = WhatsNewResource();
      await resource.load(
          bundle: _FakeAssetBundle('{"3.18.0": {"bg": ["само бг"]}}'));

      final entry = resource.entryFor('3.18.0')!;
      expect(entry.bulletsFor('en'), ['само бг']);
      expect(entry.bulletsFor('bg'), ['само бг']);
    });

    test('entryFor returns null for a version with no entry', () async {
      final resource = WhatsNewResource();
      await resource.load(
          bundle: _FakeAssetBundle('{"3.18.0": {"bg": ["x"], "en": ["x"]}}'));

      expect(resource.entryFor('3.19.1'), isNull);
    });

    test('recentEntries caps at the last three versions', () async {
      final resource = WhatsNewResource();
      await resource.load(bundle: _FakeAssetBundle('''
      {
        "1.0.0": {"bg": ["a"], "en": ["a"]},
        "2.0.0": {"bg": ["b"], "en": ["b"]},
        "3.0.0": {"bg": ["c"], "en": ["c"]},
        "4.0.0": {"bg": ["d"], "en": ["d"]}
      }
      '''));

      expect(resource.recentEntries.map((e) => e.version),
          ['4.0.0', '3.0.0', '2.0.0']);
    });

    test('a missing asset leaves entries empty instead of throwing', () async {
      final resource = WhatsNewResource();
      await resource.load(bundle: _FakeAssetBundle(null));

      expect(resource.entries, isEmpty);
    });

    test('malformed JSON leaves entries empty instead of throwing', () async {
      final resource = WhatsNewResource();
      await resource.load(bundle: _FakeAssetBundle('not json'));

      expect(resource.entries, isEmpty);
    });
  });
}
