import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MilestoneGauge extends StatelessWidget {
  final bool? animate;
  final int value;
  final int milestone;

  MilestoneGauge(this.value, this.milestone, {this.animate});

  @override
  Widget build(BuildContext context) {
    final seriesList = _createData(value, milestone, context);
    final textStyle = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          charts.PieChart(seriesList,
              animate: animate,
              defaultRenderer: new charts.ArcRendererConfig(
                  strokeWidthPx: 0,
                  arcWidth: 8,
                  startAngle: 4 / 5 * pi,
                  arcLength: 7 / 5 * pi)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(value.toString(), style: textStyle.headline6),
                Text(milestone.toString(), style: textStyle.subtitle2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createData(
      int value, int milestone, BuildContext context) {
    final data = [
      new GaugeSegment('value', value),
      new GaugeSegment('milestone', milestone - value),
    ];

    final accentColor = Theme.of(context).accentColor;
    final darkerColor = Color.lerp(accentColor, Colors.black, 0.4);
    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        colorFn: (GaugeSegment segment, i) =>
            charts.ColorUtil.fromDartColor(i == 0 ? accentColor : darkerColor!),
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        data: data,
      )
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final int size;

  GaugeSegment(this.segment, this.size);
}
