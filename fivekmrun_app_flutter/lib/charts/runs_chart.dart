import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:fivekmrun_flutter/common/pinkish_red_palette.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:intl/intl.dart';
import '../common/int_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RunsChart extends StatefulWidget {
  final List<Run> runs;

  RunsChart({key, required this.runs}) : super(key: key);

  @override
  _RunsChartState createState() => _RunsChartState();
}

class _RunsChartState extends State<RunsChart> {
  List<charts.Series<dynamic, DateTime>>? seriesList;
  String dataPointLabel = "";
  final bool? animate = true;
  static int? lowestValues;
  static int? highestValues;

  _RunsChartState();

  @override
  Widget build(BuildContext context) {
    this.seriesList = _createData(this.widget.runs);

    final theme = Theme.of(context);

    _onSelectionChanged(charts.SelectionModel model) {
      final selectedDatum = model.selectedDatum;
      String time;
      DateTime date;

      if (selectedDatum.isNotEmpty) {
        date = selectedDatum.first.datum.date;
        time = selectedDatum.first.datum.time;

        setState(() => this.dataPointLabel =
            AppLocalizations.of(context)!.runs_chart_date +
                DateFormat(Constants.DATE_FORMAT).format(date) +
                AppLocalizations.of(context)!.runs_chart_time +
                time +
                "");
        print("model: time(" + date.toString() + "), value(" + time + ")");
      }
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            IntrinsicHeight(
                child: Text(
                    AppLocalizations.of(context)!.runs_chart_trend +
                        this.widget.runs.length.toString() +
                        AppLocalizations.of(context)!.runs_chart_runs,
                    style: theme.textTheme.titleSmall)),
            IntrinsicHeight(child: Text(this.dataPointLabel)),
            Expanded(
              child: charts.TimeSeriesChart(
                seriesList!,
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
                  // // Optional - By default, select nearest is configured to trigger
                  // // with tap so that a user can have pan/zoom behavior and line point
                  // // highlighter. Changing the trigger to tap and drag allows the
                  // // highlighter to follow the dragging gesture but it is not
                  // // recommended to be used when pan/zoom behavior is enabled.
                  new charts.SelectNearest(
                      eventTrigger: charts.SelectionTrigger.tapAndDrag),
                ],
                selectionModels: [
                  new charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: _onSelectionChanged,
                  )
                ],
                primaryMeasureAxis: new charts.NumericAxisSpec(
                    viewport: new charts.NumericExtents(
                        lowestValues!, highestValues!),
                    renderSpec: charts.NoneRenderSpec()),
              ),
            )
          ],
        ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Run, DateTime>> _createData(List<Run> runs) {
    runs = runs.toList();
    lowestValues =
        minBy<Run, int>(runs, (r) => r.timeInSeconds ?? 0)?.timeInSeconds;
    highestValues =
        maxBy<Run, int>(runs, (r) => r.timeInSeconds ?? 0)?.timeInSeconds;
    runs.sort((r1, r2) => r1.date?.compareTo(r2.date!) ?? 0);

    return [
      new charts.Series<Run, DateTime>(
        id: 'Runs',
        colorFn: (Run run, i) => PinkishRedColor().makeShades(runs.length)[i!],
        domainFn: (Run run, _) => run.date!,
        measureFn: (Run run, _) => run.timeInSeconds,
        labelAccessorFn: (Run run, _) =>
            run.timeInSeconds!.parseSecondsToTimestamp(),
        data: runs,
      )
    ];
  }
}
