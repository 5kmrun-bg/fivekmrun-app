import 'package:strava_flutter/Models/activity.dart';

class FastestSplitSummary {
  final int elapsedTime;
  final double distance;

  FastestSplitSummary({
    this.elapsedTime,
    this.distance,
  });
}

class StravaSummaryRun {
  final DetailedActivity detailedActivity;
  final FastestSplitSummary fastestSplit;

  StravaSummaryRun({
    this.detailedActivity,
    this.fastestSplit,
  });
}
