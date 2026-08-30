import 'package:fivekmrun_flutter/common/pinkish_red_palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinkishRedColor.makeShades', () {
    test('always starts with the base color and ends back at it', () {
      const base = PinkishRedColor();

      for (final count in [1, 2, 3, 5]) {
        final shades = base.makeShades(count);
        expect(shades.length, count + 1,
            reason: 'makeShades($count) should return $count + 1 colors');
        expect(shades.first, base);
        expect(shades.last, base);
      }
    });

    test('the single computed shade for count 2 lightens exactly halfway',
        () {
      // steps = 2, fraction = 1/2 — exact enough to hand-verify:
      // r: 252 + (255-252)*0.5 = 253.5 -> 254 (round half away from zero)
      // g: 24  + (255-24)*0.5  = 139.5 -> 140
      // b: 81  + (255-81)*0.5  = 168 (exact)
      final shades = const PinkishRedColor().makeShades(2);

      expect(shades[1].r, 254);
      expect(shades[1].g, 140);
      expect(shades[1].b, 168);
    });

    test('interpolated shades lighten monotonically towards white', () {
      final shades = const PinkishRedColor().makeShades(4);
      // shades[0] is the base color, shades[4] is the base color again;
      // shades[1..3] are the interpolated steps in between.
      final steps = shades.sublist(1, shades.length - 1);

      for (var i = 1; i < steps.length; i++) {
        expect(steps[i].r, greaterThanOrEqualTo(steps[i - 1].r));
        expect(steps[i].g, greaterThanOrEqualTo(steps[i - 1].g));
        expect(steps[i].b, greaterThanOrEqualTo(steps[i - 1].b));
      }

      // Every step lightened relative to the base color.
      const base = PinkishRedColor();
      for (final step in steps) {
        expect(step.r, greaterThanOrEqualTo(base.r));
        expect(step.g, greaterThanOrEqualTo(base.g));
        expect(step.b, greaterThanOrEqualTo(base.b));
      }
    });

    test('keeps full alpha throughout', () {
      final shades = const PinkishRedColor().makeShades(3);
      for (final shade in shades) {
        expect(shade.a, 255);
      }
    });
  });
}
