import 'package:fivekmrun_flutter/state/kids_stats.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KidsStats.fromRuns', () {
    dynamic kidsJson({
      required int rId,
      required String nName,
      required int eDate,
      int rTime = 700,
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

    test('returns null when the user has no Kids runs', () {
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

      expect(KidsStats.fromRuns(runs), isNull);
    });

    test('counts all-time and this-year runs, ignoring non-Kids runs', () {
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
        Run.fromKidsJson(
            kidsJson(rId: 2, nName: "Южен Парк Kids", eDate: thisYearEpoch)),
        Run.fromKidsJson(
            kidsJson(rId: 3, nName: "Морска градина Варна", eDate: 1600000000)),
      ];

      final stats = KidsStats.fromRuns(runs)!;

      expect(stats.runsAllTime, 2);
      expect(stats.runsThisYear, 1);
    });

    test('sums the fixed per-run distance, unlike XL\'s parsed distance', () {
      final runs = [
        Run.fromKidsJson(
            kidsJson(rId: 1, nName: "Южен Парк Kids", eDate: 1700000000)),
        Run.fromKidsJson(kidsJson(
            rId: 2, nName: "Морска градина Варна", eDate: 1700000001)),
      ];

      final stats = KidsStats.fromRuns(runs)!;

      expect(stats.totalDistanceMeters, 2 * Run.kidsDistanceMeters);
    });

    test('best run is the fastest by time, meaningful since every Kids run '
        'is the same fixed distance', () {
      final runs = [
        Run.fromKidsJson(kidsJson(
            rId: 1, nName: "Slower", eDate: 1700000000, rTime: 800)),
        Run.fromKidsJson(kidsJson(
            rId: 2, nName: "Faster", eDate: 1700000001, rTime: 650)),
      ];

      final stats = KidsStats.fromRuns(runs)!;

      expect(stats.bestRun!.location, "Faster");
      expect(stats.bestRun!.timeInSeconds, 650);
    });

    test('most recent run is the latest by date, not by insertion order', () {
      final runs = [
        Run.fromKidsJson(
            kidsJson(rId: 1, nName: "Older", eDate: 1600000000)),
        Run.fromKidsJson(
            kidsJson(rId: 2, nName: "Newer", eDate: 1700000000)),
      ];

      final stats = KidsStats.fromRuns(runs)!;

      expect(stats.mostRecentRun!.location, "Newer");
    });
  });
}
