import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile.isTokenExpired', () {
    test('an ID-only profile never expires', () {
      final profile = Profile(userId: 1, type: ProfileType.idOnly);
      expect(profile.isTokenExpired, isFalse);
    });

    test('a password profile with a recent token is not expired', () {
      final profile = Profile(
        userId: 1,
        type: ProfileType.password,
        token: 'tkn',
        tokenTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
      expect(profile.isTokenExpired, isFalse);
    });

    test('a password profile past the 30-day window is expired', () {
      final profile = Profile(
        userId: 1,
        type: ProfileType.password,
        token: 'tkn',
        tokenTimestamp: DateTime.now()
            .subtract(const Duration(days: 31))
            .millisecondsSinceEpoch,
      );
      expect(profile.isTokenExpired, isTrue);
    });

    test('a password profile with no token is expired', () {
      final profile = Profile(userId: 1, type: ProfileType.password);
      expect(profile.isTokenExpired, isTrue);
    });
  });

  group('Profile JSON', () {
    test('round-trips every field', () {
      final profile = Profile(
        userId: 42,
        type: ProfileType.password,
        token: 'tkn',
        tokenTimestamp: 1000,
        username: 'user@example.com',
        name: 'Ivan',
        avatarUrl: 'https://example.com/a.png',
      );

      final decoded = Profile.fromJson(profile.toJson());

      expect(decoded.userId, 42);
      expect(decoded.type, ProfileType.password);
      expect(decoded.token, 'tkn');
      expect(decoded.tokenTimestamp, 1000);
      expect(decoded.username, 'user@example.com');
      expect(decoded.name, 'Ivan');
      expect(decoded.avatarUrl, 'https://example.com/a.png');
    });

    test('defaults name/avatarUrl to empty when missing', () {
      final decoded = Profile.fromJson({'userId': 1, 'type': 'idOnly'});
      expect(decoded.name, '');
      expect(decoded.avatarUrl, '');
      expect(decoded.username, isNull);
    });

    test('falls back to idOnly for an unrecognized type', () {
      final decoded =
          Profile.fromJson({'userId': 1, 'type': 'somethingUnknown'});
      expect(decoded.type, ProfileType.idOnly);
    });
  });

  group('Profile.copyWith', () {
    test('overrides only the given fields', () {
      final original = Profile(
        userId: 1,
        type: ProfileType.idOnly,
        name: 'Ivan',
        avatarUrl: 'url',
      );

      final updated = original.copyWith(name: 'Petar');

      expect(updated.userId, 1);
      expect(updated.type, ProfileType.idOnly);
      expect(updated.name, 'Petar');
      expect(updated.avatarUrl, 'url');
    });
  });
}
