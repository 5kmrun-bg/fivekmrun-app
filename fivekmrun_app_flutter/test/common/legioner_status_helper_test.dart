import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LegionStatusHelper tests', () {
    const defaultColor = Color.fromRGBO(0, 0, 0, 0);

    test('getLegionerColor should return default color', () {
      for (var runs in [0, 20, 49]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, defaultColor);
      }
    });

    test('getLegionerColor should return blue', () {
      for (var runs in [50, 80, 99]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(36, 132, 208, 1));
      }
    });

    test('getLegionerColor should return white', () {
      for (var runs in [100, 150, 199]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(202, 202, 202, 1));
      }
    });

    test('getLegionerColor should return green', () {
      for (var runs in [200, 250, 299]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(65, 170, 71, 1));
      }
    });

    test('getLegionerColor should return purple-ish', () {
      for (var runs in [300, 350, 399]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(129, 74, 177, 1));
      }
    });

    test('getLegionerColor should return red', () {
      for (var runs in [400, 450, 499]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(255, 22, 17, 1));
      }
    });

    test('getLegionerColor should return yellow', () {
      for (var runs in [500, 550, 599]) {
        var result = LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(222, 198, 62, 1));
      }
    });

    test('getLegionerColor should return brighter green', () {
      for (var runs in [600, 650, 1000, 1234, 25000]) {
        final result =
            LegionerStatusHelper.getLegionerColor(defaultColor, runs);
        expect(result, const Color.fromRGBO(50, 173, 159, 1));
      }
    });

    test('getNextMilestone should return 50', () {
      var input = [-5, 0, 25, 49];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 50);
      }
    });

    test('getNextMilestone should return 100', () {
      var input = [50, 75, 99];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 100);
      }
    });

    test('getNextMilestone should return 200', () {
      var input = [100, 150, 199];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 200);
      }
    });

    test('getNextMilestone should return 300', () {
      var input = [200, 250, 299];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 300);
      }
    });

    test('getNextMilestone should return 400', () {
      var input = [300, 350, 399];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 400);
      }
    });

    test('getNextMilestone should return 500', () {
      var input = [400, 450, 499];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 500);
      }
    });

    test('getNextMilestone should return 600', () {
      var input = [500, 550, 599];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 600);
      }
    });

    test('getNextMilestone should return 1000', () {
      var input = [600, 650, 1000, 1234, 25000];
      for (var runs in input) {
        expect(LegionerStatusHelper.getNextMilestone(runs), 1000);
      }
    });
  });
}
