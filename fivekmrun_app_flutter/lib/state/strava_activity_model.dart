import 'package:strava_flutter/Models/activity.dart';

class FastestSplitSummary {
  final int elapsedTime;
  final double distance;

  FastestSplitSummary({
    required this.elapsedTime,
    required this.distance,
  });
}

class StravaSummaryRun {
  final DetailedActivity detailedActivity;
  final FastestSplitSummary fastestSplit;

  StravaSummaryRun({
    required this.detailedActivity,
    required this.fastestSplit,
  });
}
