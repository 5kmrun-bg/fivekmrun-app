import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../common/int_extensions.dart';

class RunsChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static int lowestValues;
  static int highestValues;

  RunsChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory RunsChart.withRuns(List<Run> runs) {
    return new RunsChart(
      _createData(runs),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IntrinsicHeight(child: Text("Резултати от бягания")),
        Expanded(
          child: charts.TimeSeriesChart(
            seriesList,
            animate: animate,
            behaviors: [
              // Optional - Configures a [LinePointHighlighter] behavior with a
              // vertical follow line. A vertical follow line is included by
              // default, but is shown here as an example configuration.
              //
              // By default, the line has default dash pattern of [1,3]. This can be
              // set by providing a [dashPattern] or it can be turned off by passing in
              // an empty list. An empty list is necessary because passing in a null
              // value will be treated the same as not passing in a value at all.
              new charts.LinePointHighlighter(
                  showHorizontalFollowLine:
                      charts.LinePointHighlighterFollowLineType.none,
                  showVerticalFollowLine:
                      charts.LinePointHighlighterFollowLineType.nearest),
              // Optional - By default, select nearest is configured to trigger
              // with tap so that a user can have pan/zoom behavior and line point
              // highlighter. Changing the trigger to tap and drag allows the
              // highlighter to follow the dragging gesture but it is not
              // recommended to be used when pan/zoom behavior is enabled.
              new charts.SelectNearest(
                  eventTrigger: charts.SelectionTrigger.tapAndDrag),
            ],
            primaryMeasureAxis: new charts.NumericAxisSpec(
                viewport:
                    new charts.NumericExtents(lowestValues, highestValues),
                renderSpec: charts.NoneRenderSpec()),
          ),
        )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Run, DateTime>> _createData(List<Run> runs) {
    lowestValues = minBy<Run, int>(runs, (r) => r.timeInSeconds).timeInSeconds;
    highestValues = maxBy<Run, int>(runs, (r) => r.timeInSeconds).timeInSeconds;
    runs.sort((r1, r2) => r1.date.compareTo(r2.date));

    return [
      new charts.Series<Run, DateTime>(
        id: 'Runs',
        // colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Run run, _) => run.date,
        measureFn: (Run run, _) => run.timeInSeconds,
        labelAccessorFn: (Run run, _) =>
            run.timeInSeconds.parseSecondsToTimestamp(),
        data: runs,
      )
    ];
  }
}
