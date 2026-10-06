import 'package:fivekmrun_flutter/charts/best_times_by_route_chart.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../localized_app.dart';

const _min = 'мин';

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
      ], minutesUnit: _min);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;
      final byLocation = {for (final e in data) e.location: e.timeInSeconds};

      expect(byLocation, {'Park': 1100, 'River': 1000});
    });

    test('excludes non-official runs from the best-time calculation', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        _run(location: 'Park', timeInSeconds: 100, runType: RunType.selfie),
        _run(location: 'Park', timeInSeconds: 50, runType: RunType.xl),
      ], minutesUnit: _min);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data, hasLength(1));
      expect(data.single.timeInSeconds, 1200);
    });

    test('produces one entry per distinct route', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        _run(location: 'River', timeInSeconds: 1000),
        _run(location: 'Lake', timeInSeconds: 900),
      ], minutesUnit: _min);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data.map((e) => e.location).toSet(), {'Park', 'River', 'Lake'});
    });

    test('an empty run list produces no chart entries', () {
      final chart = BestTimesByRouteChart.withRuns(const [], minutesUnit: _min);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data, isEmpty);
    });

    test('labelAccessorFn renders the route, formatted time and unit', () {
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 125),
      ], minutesUnit: _min);

      final series = chart.seriesList.single;

      expect(series.labelAccessorFn!(0), 'Park: 02:05 мин');
    });

    test('each entry keeps the run that set the best time', () {
      final best = _run(location: 'Park', timeInSeconds: 1100);
      final chart = BestTimesByRouteChart.withRuns([
        _run(location: 'Park', timeInSeconds: 1200),
        best,
      ], minutesUnit: _min);

      final data = chart.seriesList.single.data as List<BestTimeByRouteEntry>;

      expect(data.single.run, same(best));
    });
  });

  group('BestTimesByRouteChart tap', () {
    final park = _run(location: 'Park', timeInSeconds: 1200);
    final river = _run(location: 'River', timeInSeconds: 1000);

    Future<List<Run>> pumpChart(WidgetTester tester) async {
      final tapped = <Run>[];
      await tester.pumpWidget(localizedApp(SizedBox(
        width: 400,
        height: 350,
        child: BestTimesByRouteChart.withRuns([park, river],
            minutesUnit: _min, onRunTap: tapped.add),
      )));
      await tester.pumpAndSettle();
      return tapped;
    }

    // Bars are horizontal and stacked top to bottom in data order, so the
    // upper and lower quarters of the plot land on the first and second bar.
    Offset barAt(WidgetTester tester, double fraction) {
      final rect = tester.getRect(find.byType(charts.BarChart));
      return Offset(rect.center.dx, rect.top + rect.height * fraction);
    }

    testWidgets('tapping a bar reports the run behind it', (tester) async {
      final tapped = await pumpChart(tester);

      await tester.tapAt(barAt(tester, 0.25));
      await tester.tapAt(barAt(tester, 0.75));

      expect(tapped, [same(park), same(river)]);
    });

    testWidgets('tapping the already-selected bar reports it again',
        (tester) async {
      final tapped = await pumpChart(tester);

      await tester.tapAt(barAt(tester, 0.25));
      await tester.tapAt(barAt(tester, 0.25));

      expect(tapped, [same(park), same(park)]);
    });
  });
}
