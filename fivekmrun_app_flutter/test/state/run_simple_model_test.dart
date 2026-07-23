import 'package:fivekmrun_flutter/state/run_simple_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunSimple.fromJson', () {
    test('parses id, date and derived time/pace', () {
      final r = RunSimple.fromJson({
        "s_id": 5,
        "s_cr_date": "2021-06-15T08:00:00.000",
        "s_time": 1500,
      });
      expect(r.id, 5);
      expect(r.date, DateTime.parse("2021-06-15T08:00:00.000"));
      expect(r.timeInSeconds, 1500);
      expect(r.time, "25:00");
      expect(r.pace, "05:00");
    });
  });

  group('RunSimple.listFromJson', () {
    test('maps the "runs" array', () {
      final list = RunSimple.listFromJson({
        "runs": [
          {"s_id": 1, "s_cr_date": "2021-06-15T08:00:00.000", "s_time": 1500},
          {"s_id": 2, "s_cr_date": "2021-06-16T08:00:00.000", "s_time": 1800},
        ]
      });
      expect(list, hasLength(2));
      expect(list[1].time, "30:00");
    });
  });

  group('RunSimple time helpers', () {
    test('timeInSecondsToString zero-pads and supports sign', () {
      expect(RunSimple.timeInSecondsToString(1500), "25:00");
      expect(RunSimple.timeInSecondsToString(90, sign: true), "+01:30");
    });

    test('timeInSecondsToPace returns empty for zero', () {
      expect(RunSimple.timeInSecondsToPace(0), "");
      expect(RunSimple.timeInSecondsToPace(1500), "05:00");
    });

    test('displayDate uses dd.MM.yyyy', () {
      final r = RunSimple(
        id: 1,
        date: DateTime(2021, 6, 15),
        time: "25:00",
        timeInSeconds: 1500,
        pace: "05:00",
      );
      expect(r.displayDate, "15.06.2021");
    });
  });
}
