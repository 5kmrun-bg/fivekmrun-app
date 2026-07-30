import 'package:fivekmrun_flutter/state/whats_new_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../localized_app.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  final String _content;
  _FakeAssetBundle(this._content);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _content;

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}

PackageInfo _packageInfo(String version) => PackageInfo(
      appName: '5kmRun',
      packageName: 'bg.fivekmpark.fivekmrun',
      version: version,
      buildNumber: '1',
    );

void main() {
  const assetJson = '''
  {
    "3.18.0": {"bg": ["ново в 18"], "en": ["new in 18"]},
    "3.17.0": {"bg": ["ново в 17"], "en": ["new in 17"]},
    "2.0.0": {"bg": ["ново в 2"], "en": ["new in 2"]},
    "1.0.0": {"bg": ["ново в 1"], "en": ["new in 1"]}
  }
  ''';

  testWidgets('lists versions newest-first, capped at the last three',
      (tester) async {
    await tester.pumpWidget(localizedApp(WhatsNewPage(
      bundle: _FakeAssetBundle(assetJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    )));
    await tester.pumpAndSettle();

    expect(find.text('3.18.0'), findsOneWidget);
    expect(find.text('3.17.0'), findsOneWidget);
    expect(find.text('2.0.0'), findsOneWidget);
    expect(find.text('1.0.0'), findsNothing);

    final versionTexts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((s) => s == '3.18.0' || s == '3.17.0' || s == '2.0.0')
        .toList();
    expect(versionTexts, ['3.18.0', '3.17.0', '2.0.0']);
  });

  testWidgets('shows the running app version', (tester) async {
    await tester.pumpWidget(localizedApp(WhatsNewPage(
      bundle: _FakeAssetBundle(assetJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Текуща версия: 3.18.0'), findsOneWidget);
  });

  testWidgets('shows the English bullets when the locale is English',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      WhatsNewPage(
        bundle: _FakeAssetBundle(assetJson),
        packageInfoProvider: () async => _packageInfo('3.18.0'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('• new in 18'), findsOneWidget);
    expect(find.text('• ново в 18'), findsNothing);
  });

  testWidgets('a malformed asset renders an empty list instead of crashing',
      (tester) async {
    await tester.pumpWidget(localizedApp(WhatsNewPage(
      resource: WhatsNewResource(),
      bundle: _FakeAssetBundle('not json'),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    )));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('3.18.0'), findsNothing);
  });
}
