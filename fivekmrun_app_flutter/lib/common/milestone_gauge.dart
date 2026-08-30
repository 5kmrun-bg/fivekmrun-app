import 'dart:math';

import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class MilestoneGauge extends StatelessWidget {
  final bool? animate;
  final int value;
  final int milestone;
  final Color accentColor;

  const MilestoneGauge(this.value, this.milestone, this.accentColor, {super.key, this.animate});

  @override
  Widget build(BuildContext context) {
    final seriesList = _createData(value, milestone, context);
    final textStyle = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          charts.PieChart<String>(seriesList,
              animate: animate,
              defaultRenderer: charts.ArcRendererConfig(
                  strokeWidthPx: 0,
                  arcWidth: 8,
                  startAngle: 4 / 5 * pi,
                  arcLength: 7 / 5 * pi)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(value.toString(), style: textStyle.titleLarge),
                Text(milestone.toString(), style: textStyle.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<GaugeSegment, String>> _createData(
      int value, int milestone, BuildContext context) {
    final data = [
      GaugeSegment('value', value),
      GaugeSegment('milestone', milestone - value),
    ];

    final darkerColor = Color.lerp(accentColor, Colors.black, 0.4);
    return [
      charts.Series<GaugeSegment, String>(
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
