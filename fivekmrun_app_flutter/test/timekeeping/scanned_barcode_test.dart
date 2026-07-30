import 'package:fivekmrun_flutter/timekeeping/barcode_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScannedBarcode JSON', () {
    test('round-trips isManual', () {
      final entry = ScannedBarcode(
        value: '0000012345',
        timestamp: DateTime(2026, 1, 1, 10, 30),
        isManual: true,
      );

      final decoded = ScannedBarcode.fromJson(entry.toJson());

      expect(decoded.value, '0000012345');
      expect(decoded.timestamp, DateTime(2026, 1, 1, 10, 30));
      expect(decoded.isManual, isTrue);
    });

    test(
        'defaults isManual to false when the key is missing — a session '
        'saved by a previous app version must load without error', () {
      final json = {
        'value': '0000012345',
        'timestamp': '2026-01-01T10:30:00.000',
      };

      final decoded = ScannedBarcode.fromJson(json);

      expect(decoded.isManual, isFalse);
    });
  });
}
