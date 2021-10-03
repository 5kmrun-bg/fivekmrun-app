import 'package:strava_flutter/domain/model/model_detailed_activity.dart';

class FastestSplitSummary {
  final int elapsedTime;
  final int distance;

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
