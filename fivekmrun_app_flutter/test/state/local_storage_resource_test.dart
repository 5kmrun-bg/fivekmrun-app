import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/local_storage_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          {constants.key_lastSeenWhatsNewVersion: '3.18.0'});

      final resource = LocalStorageResource();

      expect(await resource.lastSeenWhatsNewVersion, '3.18.0');
    });

    test('setLastSeenWhatsNewVersion awaits the write landing', () async {
      SharedPreferences.setMockInitialValues({});
      final resource = LocalStorageResource();

      await resource.setLastSeenWhatsNewVersion('3.19.0');

      expect(await resource.lastSeenWhatsNewVersion, '3.19.0');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(constants.key_lastSeenWhatsNewVersion),
          '3.19.0');
    });
  });
}
