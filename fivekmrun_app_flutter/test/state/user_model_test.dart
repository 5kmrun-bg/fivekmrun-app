import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  User makeUser() => User(
      id: 0, name: "", avatarUrl: "", age: 0, donationsCount: 0);

  group('User.fromJson', () {
    test('parses name, avatar and donations', () {
      final json = {
        "user": [
          {
            "u_name": "Ivan",
            "u_surname": "Petrov",
            "pic": "http://avatar/1.png",
            "u_sponsor": 3,
            "u_bdate": DateTime(1990, 1, 1).millisecondsSinceEpoch ~/ 1000,
          }
        ]
      };
      final user = User.fromJson(77, json);
      expect(user.id, 77);
      expect(user.name, "Ivan Petrov");
      expect(user.avatarUrl, "http://avatar/1.png");
      expect(user.donationsCount, 3);
    });

    test('defaults donations to zero when u_sponsor missing', () {
      final json = {
        "user": [
          {
            "u_name": "Ivan",
            "u_surname": "Petrov",
            "pic": "x",
            "u_bdate": DateTime(1990, 1, 1).millisecondsSinceEpoch ~/ 1000,
          }
        ]
      };
      expect(User.fromJson(1, json).donationsCount, 0);
    });

    test('falls back to a fake user when the record is null', () {
      final user = User.fromJson(5, {
        "user": [null]
      });
      expect(user.id, 0);
      expect(user.name, "fake user");
    });
  });

  group('User.calculateAge', () {
    test('counts full years for a birthday earlier in the year', () {
      final now = DateTime.now();
      final birth = DateTime(now.year - 30, 1, 1);
      expect(makeUser().calculateAge(birth), 30);
    });

    test('does not count the current year before the birthday month', () {
      final now = DateTime.now();
      // A birth month strictly after the current month -> not yet had birthday.
      if (now.month < 12) {
        final birth = DateTime(now.year - 30, now.month + 1, 1);
        expect(makeUser().calculateAge(birth), 29);
      }
    });
  });
}
