import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseUserId', () {
    test('parses a valid integer string', () {
      expect(parseUserId('13731'), 13731);
    });

    test('parses a valid integer with surrounding whitespace', () {
      expect(parseUserId('  42  '), 42);
    });

    test('returns null for empty string', () {
      expect(parseUserId(''), null);
    });

    test('returns null for whitespace-only string', () {
      expect(parseUserId('   '), null);
    });

    test('returns null for non-numeric input', () {
      expect(parseUserId('abc'), null);
    });

    test('returns null for alphanumeric input', () {
      expect(parseUserId('12abc'), null);
    });

    test('returns null for zero', () {
      expect(parseUserId('0'), null);
    });

    test('returns null for negative number', () {
      expect(parseUserId('-5'), null);
    });

    test('returns null for decimal input', () {
      expect(parseUserId('3.14'), null);
    });
  });
}
