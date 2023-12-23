import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LegionStatusHelper tests', () {
    final defaultColor = Color.fromRGBO(0, 0, 0, 0);

    test('getLegionerColor should return default color', () {
      [0, 20, 49].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, defaultColor);
      });
    });

    test('getLegionerColor should return blue', () {
      [50, 80, 99].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(36, 132, 208, 1));
      });
    });

    test('getLegionerColor should return white', () {
      [100, 150, 199].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(202, 202, 202, 1));
      });
    });

    test('getLegionerColor should return green', () {
      [200, 250, 299].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(65, 170, 71, 1));
      });
    });

    test('getLegionerColor should return purple-ish', () {
      [300, 350, 399].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(129, 74, 177, 1));
      });
    });

    test('getLegionerColor should return red', () {
      [400, 450, 499].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(255, 22, 17, 1));
      });
    });

    test('getLegionerColor should return yellow', () {
      [500, 550, 599].forEach((int runs) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(222, 198, 62, 1));
      });
    });

    test('getLegionerColor should return brighter green', () {
      [600, 650, 1000, 1234, 25000].forEach((int runs) {
        final result =
            LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, Color.fromRGBO(50, 173, 159, 1));
      });
    });

    test('getNextMilestone should return 50', () {
      var input = [-5, 0, 25, 49];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 50));
    });

    test('getNextMilestone should return 100', () {
      var input = [50, 75, 99];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 100));
    });

    test('getNextMilestone should return 200', () {
      var input = [100, 150, 199];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 200));
    });

    test('getNextMilestone should return 300', () {
      var input = [200, 250, 299];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 300));
    });

    test('getNextMilestone should return 400', () {
      var input = [300, 350, 399];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 400));
    });

    test('getNextMilestone should return 500', () {
      var input = [400, 450, 499];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 500));
    });

    test('getNextMilestone should return 600', () {
      var input = [500, 550, 599];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 600));
    });

    test('getNextMilestone should return 1000', () {
      var input = [600, 650, 1000, 1234, 25000];
      input.forEach((int runs) =>
          expect(LegionerStatusHelper.getNextMilestone(runs), 1000));
    });
  });
}
