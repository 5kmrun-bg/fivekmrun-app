import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Run.fromJson (official run)', () {
    final json = {
      "r_id": 123,
      "r_eventid": 45,
      "e_date": 1609459200, // 2021-01-01T00:00:00Z, in seconds
      "r_time": 1500,
      "n_name": "Sofia",
      "r_finish_pos": 5,
    };

    test('parses core fields', () {
      final run = Run.fromJson(json);
      expect(run.id, 123);
      expect(run.eventId, 45);
      expect(run.timeInSeconds, 1500);
      expect(run.location, "Sofia");
      expect(run.position, 5);
    });

    test('derives formatted time, speed and pace', () {
      final run = Run.fromJson(json);
      expect(run.time, "25:00");
      expect(run.totalTime, "25:00");
      expect(run.speed, "12.00");
      expect(run.pace, "05:00");
    });

    test('is not a selfie and defaults distance to 5000m', () {
      final run = Run.fromJson(json);
      expect(run.isSelfie, isFalse);
      expect(run.distance, 5000);
    });

    test('converts the epoch-seconds date correctly', () {
      final run = Run.fromJson(json);
      expect(run.date,
          DateTime.fromMillisecondsSinceEpoch(1609459200 * 1000));
    });
  });

  group('Run.listFromJson', () {
    test('maps the "runners" array', () {
      final json = {
        "runners": [
          {"r_id": 1, "r_eventid": 1, "e_date": 1609459200, "r_time": 1500,
            "n_name": "A", "r_finish_pos": 1},
          {"r_id": 2, "r_eventid": 1, "e_date": 1609459200, "r_time": 1800,
            "n_name": "B", "r_finish_pos": 2},
        ]
      };
      final runs = Run.listFromJson(json);
      expect(runs, hasLength(2));
      expect(runs[0].id, 1);
      expect(runs[1].timeInSeconds, 1800);
    });
  });

  group('Run.fromSelfieJson', () {
    final json = {
      "s_id": 9,
      "s_start_date": "2021-06-15T08:00:00.000",
      "s_time": 1500,
      "s_finish_pos": 2,
      "s_total_distance": 6000,
      "s_total_elapsed_time": 1800,
    };

    test('parses core fields and marks as selfie', () {
      final run = Run.fromSelfieJson(json);
      expect(run.id, 9);
      expect(run.isSelfie, isTrue);
      expect(run.eventId, isNull);
      expect(run.position, 2);
      expect(run.timeInSeconds, 1500);
      expect(run.distance, 6000);
      expect(run.time, "25:00");
      expect(run.totalTime, "30:00");
      expect(run.date, DateTime.parse("2021-06-15T08:00:00.000"));
    });

    test('falls back to defaults when distance/elapsed missing', () {
      final run = Run.fromSelfieJson({
        "s_id": 9,
        "s_start_date": "2021-06-15T08:00:00.000",
        "s_time": 1500,
        "s_finish_pos": 2,
      });
      expect(run.distance, 5000);
      expect(run.totalTime, "00:00");
    });
  });

  group('Run.selfieListFromJson', () {
    test('maps the "runs" array', () {
      final json = {
        "runs": [
          {"s_id": 1, "s_start_date": "2021-06-15T08:00:00.000", "s_time": 1500,
            "s_finish_pos": 1},
        ]
      };
      final runs = Run.selfieListFromJson(json);
      expect(runs, hasLength(1));
      expect(runs.first.isSelfie, isTrue);
    });
  });

  group('Run.timeInSecondsToString', () {
    test('zero-pads minutes and seconds', () {
      expect(Run.timeInSecondsToString(0), "00:00");
      expect(Run.timeInSecondsToString(90), "01:30");
      expect(Run.timeInSecondsToString(1500), "25:00");
    });

    test('prefixes a sign when requested', () {
      expect(Run.timeInSecondsToString(90, sign: true), "+01:30");
      expect(Run.timeInSecondsToString(-90, sign: true), "-01:30");
    });
  });

  group('Run.timeInSecondsToSpeed', () {
    test('returns empty string for zero', () {
      expect(Run.timeInSecondsToSpeed(0), "");
    });

    test('computes km/h to two decimals', () {
      expect(Run.timeInSecondsToSpeed(1500), "12.00");
    });
  });

  group('Run.timeInSecondsToPace', () {
    test('returns empty string for zero', () {
      expect(Run.timeInSecondsToPace(0), "");
    });

    test('computes mm:ss pace per km', () {
      expect(Run.timeInSecondsToPace(1500), "05:00");
    });
  });

  group('Run.distanceToString', () {
    test('formats metres as kilometres with two decimals', () {
      expect(Run.distanceToString(5000), "5.00");
      expect(Run.distanceToString(6250), "6.25");
    });
  });
}
