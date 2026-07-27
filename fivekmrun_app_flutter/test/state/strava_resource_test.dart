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

  group('describeStravaError', () {
    test('describes a Fault by its message', () {
      final fault = Fault(message: "Authorization Error");

      expect(describeStravaError(fault), "Authorization Error");
    });

    test('appends error codes from a Fault when present', () {
      final fault = Fault(message: "Bad Request", errors: [
        Error(resource: "Application", field: "refresh_token", code: "invalid")
      ]);

      expect(describeStravaError(fault),
          "Bad Request (Application:refresh_token:invalid)");
    });

    test('falls back to toString for a non-Fault error', () {
      final error = Exception("network unreachable");

      expect(describeStravaError(error), error.toString());
    });
  });

  group('fetchAuthenticatedAthleteWithRetry', () {
    DetailedAthlete athlete(int id) => DetailedAthlete(
          id: id,
          username: "runner",
          resourceState: 3,
          firstname: "First",
          lastname: "Last",
          city: "Sofia",
          state: "",
          country: "Bulgaria",
          sex: "M",
          premium: false,
          createdAt: null,
          updatedAt: null,
          badgeTypeId: 0,
          profileMedium: null,
          profile: null,
          friend: null,
          follower: null,
          followerCount: 0,
          friendCount: 0,
          mutualFriendCount: 0,
          athleteType: 0,
          datePreference: "%m/%d/%Y",
          measurementPreference: "meters",
          clubs: [],
          ftp: null,
          weight: null,
          bikes: [],
          shoes: [],
        );

    test('returns the athlete without retrying when the first call succeeds',
        () async {
      var reAuthenticateCalls = 0;

      final result = await fetchAuthenticatedAthleteWithRetry(
        () async => athlete(42),
        () async => reAuthenticateCalls++,
        reportError: (_, __, ___) {},
      );

      expect(result?.id, 42);
      expect(reAuthenticateCalls, 0);
    });

    test('re-authenticates and retries once when the first call throws',
        () async {
      var callCount = 0;
      var reAuthenticateCalls = 0;
      final reportedReasons = <String>[];

      final result = await fetchAuthenticatedAthleteWithRetry(
        () async {
          callCount++;
          if (callCount == 1) {
            throw Fault(message: "Authorization Error");
          }
          return athlete(7);
        },
        () async => reAuthenticateCalls++,
        reportError: (_, __, reason) => reportedReasons.add(reason),
      );

      expect(result?.id, 7);
      expect(reAuthenticateCalls, 1);
      expect(reportedReasons, hasLength(1));
      expect(reportedReasons.single, contains("Authorization Error"));
    });

    // Regression test for the unhandled 'Fault' exception (#167): before the
    // fix, the retry call was made without a guarding try/catch, so a second
    // failure escaped as an unhandled exception instead of being reported and
    // resolved to null.
    test('returns null instead of throwing when the retry also fails',
        () async {
      var reAuthenticateCalls = 0;
      final reportedReasons = <String>[];

      final result = await fetchAuthenticatedAthleteWithRetry(
        () async => throw Fault(message: "invalid_grant"),
        () async => reAuthenticateCalls++,
        reportError: (_, __, reason) => reportedReasons.add(reason),
      );

      expect(result, isNull);
      expect(reAuthenticateCalls, 1);
      expect(reportedReasons, hasLength(2));
      expect(reportedReasons.every((r) => r.contains("invalid_grant")), isTrue);
    });
  });
}
