import 'package:fivekmrun_flutter/charts/best_times_by_route_chart.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

Run _run({
  required String location,
  required int timeInSeconds,
  RunType runType = RunType.official,
}) {
  return Run(
    location: location,
    timeInSeconds: timeInSeconds,
    runType: runType,
    date: DateTime(2024, 1, 1),
  );
}

void main() {
  group('BestTimesByRouteChart.withRuns', () {
    test('picks the fastest official run per route', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        _run(location: 'Park', timeInSeconds: 1100),
        _run(location: 'Park', timeInSeconds: 1300),
        _run(location: 'River', timeInSeconds: 1000),
      ]);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;
      final byLocation = {for (final e in data) e.location: e.timeInSeconds};

      expect(byLocation, {'Park': 1100, 'River': 1000});
    });

    test('excludes non-official runs from the best-time calculation', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        _run(location: 'Park', timeInSeconds: 100, runType: RunType.selfie),
        _run(location: 'Park', timeInSeconds: 50, runType: RunType.xl),
      ]);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data, hasLength(1));
      expect(data.single.timeInSeconds, 1200);
    });

    test('produces one entry per distinct route', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        _run(location: 'River', timeInSeconds: 1000),
        _run(location: 'Lake', timeInSeconds: 900),
      ]);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data.map((e) => e.location).toSet(), {'Park', 'River', 'Lake'});
    });

    test('an empty run list produces no chart entries', () {
      final chart = BestTimesByRouteChart.withRuns(const []);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data, isEmpty);
    });

    test('labelAccessorFn renders the route and formatted time', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 125),
      ]);

      final series = chart.seriesList.single;

      expect(series.labelAccessorFn!(0), 'Park: 02:05');
    });
  });
}
