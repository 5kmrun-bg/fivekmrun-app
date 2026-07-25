import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strava_client/strava_client.dart';

DetailedActivity _activityWithSplits(List<SplitsMetric> splits) {
  return DetailedActivity(splitsMetric: splits);
}

SplitsMetric _split({required double distance, required int elapsedTime}) {
  return SplitsMetric(distance: distance, elapsedTime: elapsedTime);
}

void main() {
  final resource = StravaResource();

  group('createSummaryActivity', () {
    test('picks the contiguous window whose distance lands in the 5km filter range',
        () {
      // Five 1km splits at an even pace: any 5-split window sums to 5000m,
      // which is inside (stravaFilterMinDistance, stravaFilterMaxDistance).
      final activity = _activityWithSplits([
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 5000);
      expect(summary.fastestSplit.elapsedTime, 1200);
      expect(summary.detailedActivity, same(activity));
    });

    test('finds the fastest among several qualifying windows', () {
      // Splits 0-4 sum to 5000m in 1300s; splits 1-5 also sum to 5000m but
      // faster, at 1100s. The faster window must win.
      final activity = _activityWithSplits([
        _split(distance: 1000, elapsedTime: 300),
        _split(distance: 1000, elapsedTime: 200),
        _split(distance: 1000, elapsedTime: 200),
        _split(distance: 1000, elapsedTime: 200),
        _split(distance: 1000, elapsedTime: 300),
        _split(distance: 1000, elapsedTime: 200),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 5000);
      expect(summary.fastestSplit.elapsedTime, 1100);
    });

    test('skips a window that undershoots the minimum filter distance', () {
      // Only 3km total — every window stays under stravaFilterMinDistance
      // (4900m), so no window ever qualifies.
      final activity = _activityWithSplits([
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
        _split(distance: 1000, elapsedTime: 240),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 0);
      expect(summary.fastestSplit.elapsedTime, 999999);
    });

    test('skips a window that overshoots the maximum filter distance', () {
      // A single 6km split blows straight past stravaFilterMaxDistance
      // (5300m) with no smaller window available to fall back on.
      final activity = _activityWithSplits([
        _split(distance: 6000, elapsedTime: 1500),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 0);
      expect(summary.fastestSplit.elapsedTime, 999999);
    });

    test('excludes a window that lands exactly on the min boundary', () {
      // dist must be strictly greater than stravaFilterMinDistance (4900).
      final activity = _activityWithSplits([
        _split(distance: 4900, elapsedTime: 1200),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 0);
      expect(summary.fastestSplit.elapsedTime, 999999);
    });

    test('excludes a window that lands exactly on the max boundary', () {
      // dist must be strictly less than stravaFilterMaxDistance (5300).
      final activity = _activityWithSplits([
        _split(distance: 5300, elapsedTime: 1300),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 0);
      expect(summary.fastestSplit.elapsedTime, 999999);
    });

    test('a single split can qualify on its own when it lands in range', () {
      final activity = _activityWithSplits([
        _split(distance: 5100, elapsedTime: 1250),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 5100);
      expect(summary.fastestSplit.elapsedTime, 1250);
    });

    test('finds a qualifying window that starts mid-activity', () {
      // The first two splits are a slow warm-up that overshoots on its own;
      // the real 5km effort starts at index 2.
      final activity = _activityWithSplits([
        _split(distance: 2000, elapsedTime: 700),
        _split(distance: 2000, elapsedTime: 700),
        _split(distance: 1000, elapsedTime: 230),
        _split(distance: 1000, elapsedTime: 230),
        _split(distance: 1000, elapsedTime: 230),
        _split(distance: 1000, elapsedTime: 230),
        _split(distance: 1000, elapsedTime: 230),
      ]);

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 5000);
      expect(summary.fastestSplit.elapsedTime, 1150);
    });
  });
}
