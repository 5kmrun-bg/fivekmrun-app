import 'package:fivekmrun_flutter/timekeeping/manual_entry_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRunnerId', () {
    test('pads digits to the 10-digit barcode format', () {
      expect(formatRunnerId('12345'), '0000012345');
    });

    test('tolerates an already-padded 10-digit code', () {
      expect(formatRunnerId('0000012345'), '0000012345');
    });

    test('rejects empty input', () {
      expect(formatRunnerId(''), isNull);
      expect(formatRunnerId('   '), isNull);
    });

    test('rejects non-numeric input', () {
      expect(formatRunnerId('12a45'), isNull);
    });

    test('rejects more than 10 digits', () {
      expect(formatRunnerId('123456789012'), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(formatRunnerId('  123  '), '0000000123');
    });
  });

  group('formatPlace', () {
    test('prefixes with J', () {
      expect(formatPlace('001'), 'J001');
      expect(formatPlace('17'), 'J17');
    });

    test('rejects empty input', () {
      expect(formatPlace(''), isNull);
    });

    test('rejects non-numeric input', () {
      expect(formatPlace('J17'), isNull);
    });
  });

  group('stripRunnerId', () {
    test('removes the zero padding, keeping the meaningful digits', () {
      expect(stripRunnerId('0000012345'), '12345');
    });

    test('keeps at least one digit for an all-zero id', () {
      expect(stripRunnerId('0000000000'), '0');
    });
  });

  group('stripPlace', () {
    test('removes the J prefix', () {
      expect(stripPlace('J001'), '001');
    });
  });
}
