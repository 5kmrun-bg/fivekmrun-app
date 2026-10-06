import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/pinkish_red_palette.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import '../common/int_extensions.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';

class BestTimesByRouteChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  /// Called with the run behind a bar when the user taps it. The chart
  /// already selects the nearest bar on tap (that's the darker hue); this
  /// turns the selection into an action.
  final ValueChanged<Run>? onRunTap;

  const BestTimesByRouteChart(this.seriesList,
      {super.key, this.animate, this.onRunTap});

  /// [minutesUnit] is the localized unit appended to each time label (e.g.
  /// "мин"). It's passed in because the labels are built here, before
  /// `build` has a `BuildContext` to look up translations.
  factory BestTimesByRouteChart.withRuns(List<Run> runs,
      {required String minutesUnit, ValueChanged<Run>? onRunTap}) {
    return BestTimesByRouteChart(
      _createData(runs, minutesUnit),
      onRunTap: onRunTap,
    );
  }

  // `updatedListener` rather than `changedListener`: the bar stays selected
  // after a tap, so tapping it again (e.g. after coming back from the
  // results) doesn't change the selection, but should still open it.
  void _onSelectionUpdated(charts.SelectionModel<String> model) {
    if (model.selectedDatum.isEmpty) return;
    final entry = model.selectedDatum.first.datum as BestTimeByRouteEntry;
    onRunTap!(entry.run);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            IntrinsicHeight(
                child: Text(
                    AppLocalizations.of(context)!
                        .best_time_by_route_chart_widget_records,
                    style: theme.textTheme.titleSmall)),
            Expanded(
                child: charts.BarChart(seriesList,
                    animate: animate,
                    vertical: false,
                    selectionModels: [
                      if (onRunTap != null)
                        charts.SelectionModelConfig(
                            type: charts.SelectionModelType.info,
                            updatedListener: _onSelectionUpdated),
                    ],
                    barRendererDecorator:
                        charts.BarLabelDecorator<String>(),
                    // Hide domain axis.
                    domainAxis: const charts.OrdinalAxisSpec(
                        renderSpec: charts.NoneRenderSpec()),
                    primaryMeasureAxis: const charts.NumericAxisSpec(
                        renderSpec: charts.NoneRenderSpec())))
          ],
        ));
  }

  static List<charts.Series<BestTimeByRouteEntry, String>> _createData(
      List<Run> runs, String minutesUnit) {
    List<BestTimeByRouteEntry> series = groupBy<Run, String>(
            runs.where((r) => r.runType == RunType.official),
            (r) => r.location!)
        .entries
        .map((e) {
      final best = minBy<Run, int>(e.value, (r) => r.timeInSeconds ?? 0)!;
      return BestTimeByRouteEntry(e.key, best.timeInSeconds ?? 0, best);
    }).toList();

    return [
      charts.Series<BestTimeByRouteEntry, String>(
        id: 'BestTimeByRoute',
        //TODO: Add chart color to Theme
        colorFn: (_, _) => const PinkishRedColor().darker,
        domainFn: (BestTimeByRouteEntry run, _) => run.location,
        measureFn: (BestTimeByRouteEntry run, _) => run.timeInSeconds,
        labelAccessorFn: (BestTimeByRouteEntry run, _) =>
            "${run.location}: ${run.timeInSeconds.parseSecondsToTimestamp()} $minutesUnit",
        data: series,
      )
    ];
  }
}

class BestTimeByRouteEntry {
  final String location;
  final int timeInSeconds;

  /// The run that set this best time, so a tap can open its event.
  final Run run;

  BestTimeByRouteEntry(this.location, this.timeInSeconds, this.run);
}
