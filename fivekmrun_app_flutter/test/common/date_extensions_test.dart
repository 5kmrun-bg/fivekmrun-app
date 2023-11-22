import 'package:fivekmrun_flutter/common/date_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test lastSaturday extension', () {
    test('should return same day if saturday', () {
      var saturday = DateTime(2023, 9, 16);
      expect(saturday.lastSaturday().day, 16);
      expect(saturday.lastSaturday().weekday, 6);
    });

    test('should return last week\'s saturday', () {
      var saturday = DateTime(2023, 9, 15);
      expect(saturday.lastSaturday().day, 9);
      expect(saturday.lastSaturday().weekday, 6);
    });

    test('should return this week\'s saturday', () {
      var saturday = DateTime(2023, 9, 17);
      expect(saturday.lastSaturday().day, 16);
      expect(saturday.lastSaturday().weekday, 6);
    });
  });
}
