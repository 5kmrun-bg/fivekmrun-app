import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/xl_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XLStats.fromRuns', () {
    dynamic xlJson({
      required int rId,
      required String nName,
      required int eDate,
      int rTime = 3766,
    }) {
      return {
        "r_id": rId,
        "r_uid": 1,
        "r_eventid": 1,
        "r_finish_pos": 1,
        "r_time": rTime,
        "n_name": nName,
        "e_date": eDate,
      };
    }

    test('returns null when the user has no XL runs', () {
      final runs = [
        Run.fromJson({
          "r_id": 1,
          "r_eventid": 1,
          "e_date": 1609459200,
          "r_time": 1500,
          "n_name": "Sofia",
          "r_finish_pos": 1,
        }),
      ];

      expect(XLStats.fromRuns(runs), isNull);
    });

    test('counts all-time and this-year runs, ignoring non-XL runs', () {
      final now = DateTime.now();
      final thisYearEpoch =
          DateTime(now.year, 6, 1).millisecondsSinceEpoch ~/ 1000;

      final runs = [
        Run.fromJson({
          "r_id": 1,
          "r_eventid": 1,
          "e_date": 1609459200,
          "r_time": 1500,
          "n_name": "Sofia",
          "r_finish_pos": 1,
        }),
        Run.fromXLJson(
            xlJson(rId: 2, nName: "Сеславци 7.6 км", eDate: thisYearEpoch)),
        Run.fromXLJson(
            xlJson(rId: 3, nName: "Бистрица 10.0 км", eDate: 1600000000)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.runsAllTime, 2);
      expect(stats.runsThisYear, 1);
    });

    test('sums this-year distance separately from the all-time total', () {
      final now = DateTime.now();
      final thisYearEpoch =
          DateTime(now.year, 6, 1).millisecondsSinceEpoch ~/ 1000;

      final runs = [
        Run.fromXLJson(
            xlJson(rId: 1, nName: "Сеславци 7.6 км", eDate: thisYearEpoch)),
        Run.fromXLJson(
            xlJson(rId: 2, nName: "Бистрица 10.0 км", eDate: thisYearEpoch)),
        // Previous year — counts towards the all-time total only.
        Run.fromXLJson(
            xlJson(rId: 3, nName: "Витоша 5.0 км", eDate: 1600000000)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.distanceThisYearMeters, 17600);
      expect(stats.totalDistanceMeters, 22600);
    });

    test('this-year distance is null when there are no runs this year', () {
      final runs = [
        Run.fromXLJson(
            xlJson(rId: 1, nName: "Витоша 5.0 км", eDate: 1600000000)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.runsThisYear, 0);
      expect(stats.distanceThisYearMeters, isNull);
      expect(stats.totalDistanceMeters, 5000);
    });

    test('sums only distances that were parsed out of "n_name"', () {
      final runs = [
        Run.fromXLJson(
            xlJson(rId: 1, nName: "Сеславци 7.6 км", eDate: 1700000000)),
        Run.fromXLJson(
            xlJson(rId: 2, nName: "Бистрица 10.0 км", eDate: 1700000001)),
        // Unparseable name — contributes no distance, but still counts as a
        // run, and must not make the total look like a 0km run happened.
        Run.fromXLJson(
            xlJson(rId: 3, nName: "Some Unexpected Text", eDate: 1700000002)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.runsAllTime, 3);
      expect(stats.totalDistanceMeters, 17600);
    });

    test('total distance is null when no XL run has a parseable distance', () {
      final runs = [
        Run.fromXLJson(
            xlJson(rId: 1, nName: "Some Unexpected Text", eDate: 1700000000)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.totalDistanceMeters, isNull);
    });

    test('most recent run is the latest by date, not by insertion order', () {
      final runs = [
        Run.fromXLJson(
            xlJson(rId: 1, nName: "Older 5.0 км", eDate: 1600000000)),
        Run.fromXLJson(
            xlJson(rId: 2, nName: "Newer 10.0 км", eDate: 1700000000)),
      ];

      final stats = XLStats.fromRuns(runs)!;

      expect(stats.mostRecentRun!.location, "Newer");
    });
  });

  group('nextUpcomingXLEvent', () {
    final now = DateTime(2026, 7, 26, 14, 0);

    dynamic xlEventRow({required int id, required DateTime date}) {
      return {
        "e_id": id,
        "e_num": id,
        "n_name": "с. Кътина 4.8 км",
        "e_date": date.millisecondsSinceEpoch ~/ 1000,
        "e_time": "9:00",
      };
    }

    XLEvent xlEvent({required int id, required DateTime date}) {
      return Event.listFromXLJson([xlEventRow(id: id, date: date)]).first
          as XLEvent;
    }

    test('returns null when there are no XL events at all', () {
      expect(nextUpcomingXLEvent(<Event>[], now: now), isNull);
    });

    test('returns null when every XL event is in the past', () {
      final events = <Event>[
        xlEvent(id: 1, date: DateTime(2026, 7, 1)),
        xlEvent(id: 2, date: DateTime(2026, 6, 1)),
      ];

      expect(nextUpcomingXLEvent(events, now: now), isNull);
    });

    test('picks the soonest upcoming event regardless of list order', () {
      final events = <Event>[
        xlEvent(id: 1, date: DateTime(2026, 9, 5)),
        xlEvent(id: 2, date: DateTime(2026, 8, 1)),
        xlEvent(id: 3, date: DateTime(2026, 7, 1)),
      ];

      expect(nextUpcomingXLEvent(events, now: now)!.id, 2);
    });

    test("today's event still counts as upcoming", () {
      final events = <Event>[
        xlEvent(id: 1, date: DateTime(2026, 7, 26, 9, 0)),
        xlEvent(id: 2, date: DateTime(2026, 8, 1)),
      ];

      expect(nextUpcomingXLEvent(events, now: now)!.id, 1);
    });

    test('ignores non-XL events', () {
      final events = <Event>[
        ...Event.listFromJson([
          {
            "e_id": 99,
            "e_title": "Редовно бягане",
            "e_date": DateTime(2026, 7, 27).millisecondsSinceEpoch ~/ 1000,
            "e_time": "9:00",
            "n_name": "Южен парк",
            "e_sponsor": "",
          }
        ]),
        xlEvent(id: 2, date: DateTime(2026, 8, 1)),
      ];

      expect(nextUpcomingXLEvent(events, now: now)!.id, 2);
    });
  });
}
