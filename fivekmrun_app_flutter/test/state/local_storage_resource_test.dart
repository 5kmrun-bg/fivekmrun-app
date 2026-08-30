import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// A store whose writes take a real async gap to land.
///
/// Needed because `SharedPreferences.setString` updates its own in-memory
/// cache synchronously, so reading back through `SharedPreferences` succeeds
/// whether or not the write was awaited. Only the platform store below can
/// tell the two apart.
class _SlowWriteStore extends SharedPreferencesStorePlatform {
  final InMemorySharedPreferencesStore _inner =
      InMemorySharedPreferencesStore.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _inner.setValue(valueType, key, value);
  }

  @override
  Future<Map<String, Object>> getAll() => _inner.getAll();

  @override
  Future<bool> remove(String key) => _inner.remove(key);

  @override
  Future<bool> clear() => _inner.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('isSubscribedForGeneral', () {
    test('defaults to false when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});

      final resource = LocalStorageResource();

      expect(await resource.isSubscribedForGeneral, isFalse);
    });

    test('reflects a previously saved value', () async {
      SharedPreferences.setMockInitialValues(
          {'push_notifications_subscribed_general': true});

      final resource = LocalStorageResource();

      expect(await resource.isSubscribedForGeneral, isTrue);
    });

    test('setter persists the value for later reads', () async {
      SharedPreferences.setMockInitialValues({});
      final resource = LocalStorageResource();

      resource.isSubscrubedForGeneral = true;
      // The setter is fire-and-forget; wait for the write to land.
      await Future<void>.delayed(Duration.zero);

      expect(await resource.isSubscribedForGeneral, isTrue);
      final preferences = await SharedPreferences.getInstance();
      expect(
          preferences.getBool('push_notifications_subscribed_general'), isTrue);
    });
  });

  group('lastSeenWhatsNewVersion', () {
    test('is null on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});

      final resource = LocalStorageResource();

      expect(await resource.lastSeenWhatsNewVersion, isNull);
    });

    test('reflects a previously saved version', () async {
      SharedPreferences.setMockInitialValues(
          {constants.keyLastSeenWhatsNewVersion: '3.18.0'});

      final resource = LocalStorageResource();

      expect(await resource.lastSeenWhatsNewVersion, '3.18.0');
    });

    test('setLastSeenWhatsNewVersion persists the version for later reads',
        () async {
      SharedPreferences.setMockInitialValues({});
      final resource = LocalStorageResource();

      await resource.setLastSeenWhatsNewVersion('3.19.0');

      expect(await resource.lastSeenWhatsNewVersion, '3.19.0');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(constants.keyLastSeenWhatsNewVersion),
          '3.19.0');
    });

    test('setLastSeenWhatsNewVersion does not return before the write lands',
        () async {
      // Drop the cached singleton so the resource picks up the slow store.
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = _SlowWriteStore();
      addTearDown(() {
        SharedPreferences.resetStatic();
        SharedPreferences.setMockInitialValues({});
      });

      final resource = LocalStorageResource();

      await resource.setLastSeenWhatsNewVersion('3.19.0');

      // Asserted against the platform store, not SharedPreferences: the
      // latter caches the value synchronously and would report it even with
      // the write still in flight. If the setter stops awaiting, this read
      // happens 50ms before the write lands and the key is absent.
      final stored = await SharedPreferencesStorePlatform.instance.getAll();
      expect(stored['flutter.${constants.keyLastSeenWhatsNewVersion}'],
          '3.19.0');
    });
  });
}
