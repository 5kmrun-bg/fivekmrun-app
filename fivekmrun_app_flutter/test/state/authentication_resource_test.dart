import 'dart:convert';

import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _profilesJson(List<Profile> profiles) =>
    jsonEncode(profiles.map((p) => p.toJson()).toList());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('authenticateWithUserId', () {
    test('adds an ID-only profile and makes it active by default', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();

      final result = await auth.authenticateWithUserId(111);

      expect(result, isTrue);
      expect(auth.getUserId(), 111);
      expect(auth.getToken(), isNull);
      expect(auth.isLoggedIn(), isFalse);
      expect(auth.profiles, hasLength(1));
      expect(auth.profiles.single.type, ProfileType.idOnly);
    });

    test('adding with makeActive: false keeps the current profile active',
        () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);

      await auth.authenticateWithUserId(222, makeActive: false);

      expect(auth.getUserId(), 111);
      expect(auth.profiles.map((p) => p.userId), containsAll([111, 222]));
    });

    test('re-adding an existing profile refreshes it instead of duplicating',
        () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111, makeActive: false);

      await auth.authenticateWithUserId(111);

      expect(auth.profiles, hasLength(1));
      expect(auth.getUserId(), 111);
    });

    test('rejects a genuinely new profile once at the cap', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      for (var i = 0; i < constants.maxProfiles; i++) {
        await auth.authenticateWithUserId(i, makeActive: false);
      }

      await expectLater(
        auth.authenticateWithUserId(999, makeActive: false),
        throwsA(isA<MaxProfilesReachedException>()),
      );
      expect(auth.profiles, hasLength(constants.maxProfiles));
    });

    test('persists the profile list and active id', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();

      await auth.authenticateWithUserId(111);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(constants.key_profiles), isNotNull);
      expect(prefs.getInt(constants.key_activeProfileId), 111);
    });
  });

  group('switchProfile', () {
    test('switches to a saved profile', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);
      await auth.authenticateWithUserId(222, makeActive: false);

      final result = await auth.switchProfile(222);

      expect(result, isTrue);
      expect(auth.getUserId(), 222);
    });

    test(
        'returns false and leaves the active profile unchanged for an '
        'unknown id', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);

      final result = await auth.switchProfile(999);

      expect(result, isFalse);
      expect(auth.getUserId(), 111);
    });
  });

  group('removeProfile', () {
    test('removing a non-active profile leaves the active one unchanged',
        () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);
      await auth.authenticateWithUserId(222, makeActive: false);

      final newActive = await auth.removeProfile(222);

      expect(newActive, 111);
      expect(auth.getUserId(), 111);
      expect(auth.profiles, hasLength(1));
    });

    test('removing the active profile falls back to another saved profile',
        () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);
      await auth.authenticateWithUserId(222, makeActive: false);

      final newActive = await auth.removeProfile(111);

      expect(newActive, 222);
      expect(auth.getUserId(), 222);
    });

    test('removing the last profile leaves no active profile', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);

      final newActive = await auth.removeProfile(111);

      expect(newActive, isNull);
      expect(auth.getUserId(), isNull);
      expect(auth.profiles, isEmpty);
    });
  });

  group('logout', () {
    test('clears every saved profile', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);
      await auth.authenticateWithUserId(222, makeActive: false);

      await auth.logout();

      expect(auth.profiles, isEmpty);
      expect(auth.getUserId(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(constants.key_profiles), isNull);
      expect(prefs.getInt(constants.key_activeProfileId), isNull);
    });
  });

  group('updateProfileDisplay', () {
    test('updates the cached name/avatar for a saved profile', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);

      await auth.updateProfileDisplay(111,
          name: 'Ivan', avatarUrl: 'https://example.com/a.png');

      expect(auth.profiles.single.name, 'Ivan');
      expect(auth.profiles.single.avatarUrl, 'https://example.com/a.png');
    });

    test('is a no-op for an unknown profile id', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();
      await auth.authenticateWithUserId(111);

      await auth.updateProfileDisplay(999, name: 'X', avatarUrl: 'Y');

      expect(auth.profiles.single.name, '');
    });
  });

  group('loadFromLocalStore', () {
    test('loads an already-saved profile list', () async {
      final profiles = [
        const Profile(userId: 111, type: ProfileType.idOnly, name: 'A'),
        Profile(
            userId: 222,
            type: ProfileType.password,
            token: 'tkn',
            tokenTimestamp: DateTime.now().millisecondsSinceEpoch,
            name: 'B'),
      ];
      SharedPreferences.setMockInitialValues({
        constants.key_profiles: _profilesJson(profiles),
        constants.key_activeProfileId: 222,
      });
      final auth = AuthenticationResource();

      await auth.loadFromLocalStore();

      expect(auth.profiles.map((p) => p.userId), [111, 222]);
      expect(auth.getUserId(), 222);
      expect(auth.isLoggedIn(), isTrue);
    });

    test('migrates the pre-multi-profile single password-account keys',
        () async {
      SharedPreferences.setMockInitialValues({
        constants.key_userId: 555,
        constants.key_token: 'legacy-token',
        constants.key_tokenTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
      final auth = AuthenticationResource();

      await auth.loadFromLocalStore();

      expect(auth.profiles, hasLength(1));
      expect(auth.profiles.single.userId, 555);
      expect(auth.profiles.single.type, ProfileType.password);
      expect(auth.getUserId(), 555);
      expect(auth.getToken(), 'legacy-token');
      expect(auth.isLoggedIn(), isTrue);

      // The migration is persisted, so a following launch reads the new
      // profiles list directly rather than re-migrating.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(constants.key_profiles), isNotNull);
    });

    test('migrates the pre-multi-profile single ID-only account', () async {
      SharedPreferences.setMockInitialValues({
        constants.key_userId: 555,
      });
      final auth = AuthenticationResource();

      await auth.loadFromLocalStore();

      expect(auth.profiles.single.type, ProfileType.idOnly);
      expect(auth.getUserId(), 555);
      expect(auth.isLoggedIn(), isFalse);
    });

    test('an expired migrated token is not usable, but the identity is kept',
        () async {
      SharedPreferences.setMockInitialValues({
        constants.key_userId: 555,
        constants.key_token: 'legacy-token',
        constants.key_tokenTimestamp: DateTime.now()
            .subtract(const Duration(days: 31))
            .millisecondsSinceEpoch,
      });
      final auth = AuthenticationResource();

      await auth.loadFromLocalStore();

      expect(auth.getUserId(), 555);
      expect(auth.getToken(), isNull);
      expect(auth.isLoggedIn(), isFalse);
    });

    test('starts with no profiles on a fresh install', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthenticationResource();

      await auth.loadFromLocalStore();

      expect(auth.profiles, isEmpty);
      expect(auth.getUserId(), isNull);
    });
  });
}
