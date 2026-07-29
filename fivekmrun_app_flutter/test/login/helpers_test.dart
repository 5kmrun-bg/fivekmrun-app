import 'package:fivekmrun_flutter/login/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseUserId', () {
    test('parses a plain positive integer', () {
      expect(parseUserId('12345'), 12345);
    });

    test('trims surrounding whitespace', () {
      expect(parseUserId('  42  '), 42);
    });

    test('returns null for an empty string', () {
      expect(parseUserId(''), isNull);
    });

    test('returns null for a whitespace-only string', () {
      expect(parseUserId('   '), isNull);
    });

    test('returns null for non-numeric input', () {
      expect(parseUserId('abc'), isNull);
    });

    test('returns null for zero', () {
      expect(parseUserId('0'), isNull);
    });

    test('returns null for a negative number', () {
      expect(parseUserId('-5'), isNull);
    });

    test('returns null for a decimal value', () {
      expect(parseUserId('12.5'), isNull);
    });
  });

  group('InputHelpers.decoration', () {
    test('sets the label text to the given hint', () {
      final decoration = InputHelpers.decoration('email');
      expect(decoration.labelText, 'email');
    });

    test('uses a square-cornered outline border', () {
      final decoration = InputHelpers.decoration('email');
      final border = decoration.border as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.all(Radius.circular(0)));
    });
  });

  group('getSwatch', () {
    test('returns all ten Material swatch steps', () {
      final swatch = getSwatch(Colors.blue);
      expect(
        swatch.keys.toSet(),
        {50, 100, 200, 300, 400, 500, 600, 700, 800, 900},
      );
    });

    test('keeps the input color as the 500 step', () {
      final color = Color(0xFF336699);
      final swatch = getSwatch(color);
      expect(swatch[500], color);
    });

    test('gets lighter as the step number decreases from 500', () {
      final swatch = getSwatch(Colors.blue);
      final lightness50 = HSLColor.fromColor(swatch[50]!).lightness;
      final lightness100 = HSLColor.fromColor(swatch[100]!).lightness;
      final lightness500 = HSLColor.fromColor(swatch[500]!).lightness;
      expect(lightness50, greaterThan(lightness100));
      expect(lightness100, greaterThan(lightness500));
    });

    test('gets darker as the step number increases from 500', () {
      final swatch = getSwatch(Colors.blue);
      final lightness500 = HSLColor.fromColor(swatch[500]!).lightness;
      final lightness800 = HSLColor.fromColor(swatch[800]!).lightness;
      final lightness900 = HSLColor.fromColor(swatch[900]!).lightness;
      expect(lightness800, lessThan(lightness500));
      expect(lightness900, lessThan(lightness800));
    });
  });

  group('getColor', () {
    test('builds a MaterialColor whose value matches the input color', () {
      final color = Color(0xFF336699);
      final materialColor = getColor(color);
      expect(materialColor.value, color.value);
    });

    test('exposes the same swatch getSwatch would produce', () {
      final color = Colors.green;
      final materialColor = getColor(color);
      final swatch = getSwatch(color);
      expect(materialColor[500], swatch[500]);
      expect(materialColor[900], swatch[900]);
    });
  });
}
