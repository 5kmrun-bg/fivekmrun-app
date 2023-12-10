import 'package:fivekmrun_flutter/common/double_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test metersToKm double extension', () {
    test('should strip after 2nd point', () {
      expect(3521.5.metersToKm(), '3.52');
    });

    test('should round properly', () {
      expect(3499.9.metersToKm(), '3.50');
      expect(3455.0.metersToKm(), '3.46');
      expect(3454.9.metersToKm(), '3.45');
    });

    test('should convert negatives', () {
      expect((-4000.0).metersToKm(), '-4.00');
    });

    test('should validate 0', () {
      expect(0.0.metersToKm(), '0.00');
      expect((-0.0).metersToKm(), '-0.00');
    });
  });
}
