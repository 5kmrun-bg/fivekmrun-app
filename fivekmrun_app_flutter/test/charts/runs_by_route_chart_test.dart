import 'package:fivekmrun_flutter/charts/runs_by_route_chart.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter_test/flutter_test.dart';

Run _run({
  required String location,
  int timeInSeconds = 0,
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
  group('RunsByRouteChart.withRuns', () {
    test('counts official runs per route', () {
      final chart = RunsByRouteChart.withRuns([
        _run(location: 'Park'),
        _run(location: 'Park'),
        _run(location: 'River'),
      ]);

      final data = chart.seriesList.single.data as List<RunsByRouteEntry>;
      final byLocation = {for (final e in data) e.location: e.timeInSeconds};

      expect(byLocation, {'Park': 2, 'River': 1});
    });

    test('excludes non-official runs from the route breakdown', () {
      final chart = RunsByRouteChart.withRuns([
        _run(location: 'Park'),
        _run(location: 'Park', runType: RunType.selfie),
        _run(location: 'Park', runType: RunType.xl),
      ]);

      final data = chart.seriesList.single.data as List<RunsByRouteEntry>;

      expect(data, hasLength(1));
      expect(data.single.timeInSeconds, 1);
    });

    test('produces one entry per distinct route', () {
      final chart = RunsByRouteChart.withRuns([
        _run(location: 'Park'),
        _run(location: 'River'),
        _run(location: 'Lake'),
      ]);

      final data = chart.seriesList.single.data as List<RunsByRouteEntry>;

      expect(data.map((e) => e.location).toSet(), {'Park', 'River', 'Lake'});
    });

    test('an empty run list produces no chart entries', () {
      final chart = RunsByRouteChart.withRuns(const []);

      final data = chart.seriesList.single.data as List<RunsByRouteEntry>;

      expect(data, isEmpty);
    });

    test('labelAccessorFn renders the run count for the route', () {
      final chart = RunsByRouteChart.withRuns([
        _run(location: 'Park'),
        _run(location: 'Park'),
        _run(location: 'Park'),
      ]);

      final series = chart.seriesList.single;

      expect(series.labelAccessorFn!(0), '3');
    });

    test('colorFn wraps around the palette once routes exceed its length', () {
      const paletteLength = 5;
      final chart = RunsByRouteChart.withRuns([
        for (var i = 0; i < paletteLength + 2; i++) _run(location: 'Route$i'),
      ]);

      final series = chart.seriesList.single;

      expect(series.colorFn!(paletteLength), series.colorFn!(0));
      expect(series.colorFn!(paletteLength + 1), series.colorFn!(1));
    });
  });
}
