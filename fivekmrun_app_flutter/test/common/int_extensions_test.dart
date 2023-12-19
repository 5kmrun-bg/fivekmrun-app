import 'package:fivekmrun_flutter/common/int_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test parseSecondsToTimestamp int extension', () {
    test('should display round values', () {
      expect(0.parseSecondsToTimestamp(), '00:00');
      expect(60.parseSecondsToTimestamp(), '01:00');
      expect(3600.parseSecondsToTimestamp(), '01:00:00');
    });

    test('should display seconds', () {
      expect(23.parseSecondsToTimestamp(), '00:23');
    });

    test('should display minutes and seconds', () {
      expect(1891.parseSecondsToTimestamp(), '31:31');
    });

    test('should display hours, minutes and seconds', () {
      expect(3891.parseSecondsToTimestamp(), '01:04:51');
      expect(86401.parseSecondsToTimestamp(), '24:00:01');
    });
  });
}
