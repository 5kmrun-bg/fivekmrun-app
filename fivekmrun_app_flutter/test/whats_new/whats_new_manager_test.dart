import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:fivekmrun_flutter/state/whats_new_resource.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_manager.dart';
import 'package:fivekmrun_flutter/whats_new/whats_new_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<WhatsNewResource> _loadedResource(String assetJson) async {
  final resource = WhatsNewResource();
  await resource.load(bundle: _FakeAssetBundle(assetJson));
  return resource;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const entryJson = '{"3.18.0": {"bg": ["ново"], "en": ["new stuff"]}}';

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(localizedApp(Builder(builder: (context) {
      captured = context;
      return const SizedBox();
    })));
    return captured;
  }

  testWidgets('fresh install: no popup, stores the current version',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isFalse);
    expect(find.byType(WhatsNewSheet), findsNothing);
    expect(await LocalStorageResource().lastSeenWhatsNewVersion, '3.18.0');
  });

  testWidgets('same-version relaunch: no popup', (tester) async {
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.18.0'});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isFalse);
    expect(find.byType(WhatsNewSheet), findsNothing);
  });

  testWidgets('downgrade / debug build: no popup', (tester) async {
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.18.0'});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.9.0'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isFalse);
  });

  testWidgets(
      'upgrade to a version with no archive entry: no popup, version still advances',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.18.0'});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.18.1'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isFalse);
    expect(find.byType(WhatsNewSheet), findsNothing);
    expect(await LocalStorageResource().lastSeenWhatsNewVersion, '3.18.1');
  });

  testWidgets(
      'upgrade with an entry shows the sheet and advances the stored version',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.9.0'});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isTrue);
    expect(find.byType(WhatsNewSheet), findsOneWidget);
    expect(find.text('• ново'), findsOneWidget);
    expect(await LocalStorageResource().lastSeenWhatsNewVersion, '3.18.0');
  });

  testWidgets('semver comparison treats 3.9.0 as older than 3.18.0, not newer',
      (tester) async {
    // A naive string compare puts "3.9.0" after "3.18.0" and would suppress
    // this upgrade's popup.
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.9.0'});
    final context = await pumpContext(tester);
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource(entryJson),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    );

    final shown = await manager.maybeShowPopup(context);
    await tester.pumpAndSettle();

    expect(shown, isTrue);
  });

  testWidgets('falls back to bg when the active locale has no bullets',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {constants.key_lastSeenWhatsNewVersion: '3.9.0'});
    late BuildContext captured;
    await tester.pumpWidget(localizedApp(
      Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      }),
      locale: const Locale('en'),
    ));
    final manager = WhatsNewManager(
      localStorage: LocalStorageResource(),
      resource: await _loadedResource('{"3.18.0": {"bg": ["само бг"]}}'),
      packageInfoProvider: () async => _packageInfo('3.18.0'),
    );

    final shown = await manager.maybeShowPopup(captured);
    await tester.pumpAndSettle();

    expect(shown, isTrue);
    expect(find.text('• само бг'), findsOneWidget);
  });
}
