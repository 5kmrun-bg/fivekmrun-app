import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Run.fromXLJson', () {
    dynamic xlResultJson({
      String nName = "Сеславци 7.6 км",
      int rTime = 3766,
    }) {
      return {
        "r_id": 29638,
        "r_uid": 13731,
        "r_eventid": 392,
        "r_finish_pos": 60,
        "r_time": rTime,
        "n_name": nName,
        "e_date": 1783803600,
      };
    }

    test('parses the place name out of "n_name", dropping the distance', () {
      final run = Run.fromXLJson(xlResultJson(nName: "с. Кътина 14.4 км"));
      expect(run.location, "с. Кътина");
    });

    test('parses the distance out of "n_name" into meters', () {
      final run = Run.fromXLJson(xlResultJson(nName: "Сеславци 7.6 км"));
      expect(run.distance, 7600);
    });

    test('falls back to the raw text when "n_name" has no distance suffix',
        () {
      final run = Run.fromXLJson(xlResultJson(nName: "Some Unexpected Text"));
      expect(run.location, "Some Unexpected Text");
      expect(run.distance, null);
    });

    test('marks the run as XL and not selfie', () {
      final run = Run.fromXLJson(xlResultJson());
      expect(run.isXL, true);
      expect(run.isSelfie, false);
    });

    test('computes pace/speed off the real distance, not a fixed 5km', () {
      final fiveK = Run.fromXLJson(xlResultJson(nName: "Route 5.0 км", rTime: 1200));
      final tenK = Run.fromXLJson(xlResultJson(nName: "Route 10.0 км", rTime: 2400));

      // Same pace (4 min/km) at double the distance and double the time.
      expect(fiveK.pace, tenK.pace);
    });
  });

  group('Run.listFromXLUserJson', () {
    test('merges "runners" and "years[].results", de-duplicated by r_id', () {
      final json = {
        "runners": [
          {
            "r_id": 1,
            "r_eventid": 100,
            "r_time": 1000,
            "r_finish_pos": 1,
            "n_name": "A 5.0 км",
            "e_date": 1700000000,
          }
        ],
        "years": [
          {
            "yr": "2023",
            "results": [
              {
                "r_id": 1, // duplicate of the "runners" entry above
                "r_eventid": 100,
                "r_time": 1000,
                "r_finish_pos": 1,
                "n_name": "A 5.0 км",
                "e_date": 1700000000,
              },
              {
                "r_id": 2,
                "r_eventid": 101,
                "r_time": 2000,
                "r_finish_pos": 5,
                "n_name": "B 10.0 км",
                "e_date": 1600000000,
              },
            ],
          }
        ],
      };

      final runs = Run.listFromXLUserJson(json);

      expect(runs.length, 2);
      expect(runs.map((r) => r.id).toSet(), {1, 2});
    });

    test('handles missing "runners"/"years" gracefully', () {
      expect(Run.listFromXLUserJson({}), isEmpty);
    });
  });

  group('timeInSecondsToSpeed/timeInSecondsToPace distance parameter', () {
    test('defaults to the 5km assumption used by official/selfie runs', () {
      expect(Run.timeInSecondsToSpeed(1200),
          Run.timeInSecondsToSpeed(1200, distanceMeters: 5000));
      expect(Run.timeInSecondsToPace(1200),
          Run.timeInSecondsToPace(1200, distanceMeters: 5000));
    });
  });
}
