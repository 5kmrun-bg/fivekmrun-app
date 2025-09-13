import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/pinkish_red_palette.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import '../common/int_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class BestTimesByRouteChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  BestTimesByRouteChart(this.seriesList, {this.animate});

  factory BestTimesByRouteChart.withRuns(List<Run> runs) {
    return new BestTimesByRouteChart(
      _createData(runs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            IntrinsicHeight(
                child: Text(AppLocalizations.of(context)!.best_time_by_route_chart_widget_records,
                    style: theme.textTheme.titleSmall)),
            Expanded(
                child: charts.BarChart(seriesList,
                    animate: this.animate,
                    vertical: false,
                    barRendererDecorator:
                        new charts.BarLabelDecorator<String>(),
                    // Hide domain axis.
                    domainAxis: new charts.OrdinalAxisSpec(
                        renderSpec: new charts.NoneRenderSpec()),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                        renderSpec: charts.NoneRenderSpec())))
          ],
        ));
  }

  static List<charts.Series<BestTimeByRouteEntry, String>> _createData(
      List<Run> runs) {
    List<BestTimeByRouteEntry> series =
        groupBy<Run, String>(runs.where((r) => !r.isSelfie), (r) => r.location!)
            .entries
            .map((e) => BestTimeByRouteEntry(
                e.key,
                minBy<Run, int>(e.value, (r) => r.timeInSeconds ?? 0)
                        ?.timeInSeconds ??
                    0))
            .toList();

    return [
      new charts.Series<BestTimeByRouteEntry, String>(
        id: 'BestTimeByRoute',
        //TODO: Add chart color to Theme
        colorFn: (_, __) => PinkishRedColor().darker,
        domainFn: (BestTimeByRouteEntry run, _) => run.location,
        measureFn: (BestTimeByRouteEntry run, _) => run.timeInSeconds,
        labelAccessorFn: (BestTimeByRouteEntry run, _) =>
            "${run.location}: ${run.timeInSeconds.parseSecondsToTimestamp()}",
        data: series,
      )
    ];
  }
}

class BestTimeByRouteEntry {
  final String location;
  final int timeInSeconds;

  BestTimeByRouteEntry(this.location, this.timeInSeconds);
}
