import 'package:fivekmrun_flutter/common/pinkish_red_palette.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import "package:collection/collection.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RunsByRouteChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  RunsByRouteChart(this.seriesList, {this.animate});

  factory RunsByRouteChart.withRuns(List<Run> runs) {
    return new RunsByRouteChart(
      _createData(runs),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subTitleStyle = theme.textTheme.titleSmall;

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          IntrinsicHeight(
              child: Text(AppLocalizations.of(context)!.runs_by_route_chart_title, style: subTitleStyle)),
          Expanded(
              child: new charts.PieChart<String>(seriesList,
                  animate: animate,
                  defaultRenderer: new charts.ArcRendererConfig(
                      arcWidth: 60,
                      arcRendererDecorators: [
                        new charts.ArcLabelDecorator(
                            outsideLabelStyleSpec: charts.TextStyleSpec(
                                fontSize: 12, color: charts.Color.white))
                      ]),
                  behaviors: [
                new charts.DatumLegend(
                  // Positions for "start" and "end" will be left and right respectively
                  // for widgets with a build context that has directionality ltr.
                  // For rtl, "start" and "end" will be right and left respectively.
                  // Since this example has directionality of ltr, the legend is
                  // positioned on the right side of the chart.
                  position: charts.BehaviorPosition.end,
                  // For a legend that is positioned on the left or right of the chart,
                  // setting the justification for [endDrawArea] is aligned to the
                  // bottom of the chart draw area.
                  //outsideJustification: charts.OutsideJustification.endDrawArea,
                  // By default, if the position of the chart is on the left or right of
                  // the chart, [horizontalFirst] is set to false. This means that the
                  // legend entries will grow as new rows first instead of a new column.
                  horizontalFirst: false,
                  // This defines the padding around each legend entry.
                  cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                )
              ])),
        ]));
  }

  static List<charts.Series<RunsByRouteEntry, String>> _createData(
      List<Run> runs) {
    List<RunsByRouteEntry> series =
        groupBy<Run, String>(runs.where((r) => !r.isSelfie), (r) => r.location!)
            .entries
            .map((e) => RunsByRouteEntry(e.key, e.value.length))
            .toList();

    return [
      new charts.Series<RunsByRouteEntry, String>(
        id: 'RunsByRoute',
        colorFn: (_, i) => PinkishRedColor()
            .getPalette()[i! % PinkishRedColor().getPalette().length],
        domainFn: (RunsByRouteEntry run, _) => run.location,
        measureFn: (RunsByRouteEntry run, _) => run.timeInSeconds,
        data: series,
        labelAccessorFn: (RunsByRouteEntry run, _) =>
            run.timeInSeconds.toString(),
      )
    ];
  }
}

class RunsByRouteEntry {
  final String location;
  final int timeInSeconds;

  RunsByRouteEntry(this.location, this.timeInSeconds);
}
