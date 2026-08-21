import 'dart:convert';
import 'dart:io';

import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/state/strava_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strava_client/strava_client.dart';

const _fixturesDir = 'test/fixtures/strava';

Map<String, dynamic> _loadFixture(String name) {
  return jsonDecode(File('$_fixturesDir/$name.json').readAsStringSync())
      as Map<String, dynamic>;
}

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

  // Regression coverage for the strava_client fork -> pub.dev 2.3.1 migration
  // (#221): the fork's hand-written parsing coerced several numeric fields
  // (elevation gain, calories, max speed) that Strava sometimes returns as
  // integers rather than doubles. 2.3.1's json_serializable codegen reads
  // every numeric field as `num?` then coerces, so these fixtures exercise
  // that path across the run shapes the app actually sees.
  group('DetailedActivity.fromJson fixtures', () {
    for (final name in [
      'run_5k_typical',
      'run_manual_treadmill',
      'run_no_gps',
      'run_sub_5k',
      'run_ultra_multilap',
      'ride_not_a_run',
    ]) {
      test('$name deserialises without throwing', () {
        final activity = DetailedActivity.fromJson(_loadFixture(name));

        expect(activity.id, isNotNull);
      });
    }

    test('coerces an integer total_elevation_gain to double', () {
      final activity =
          DetailedActivity.fromJson(_loadFixture('run_manual_treadmill'));

      expect(activity.totalElevationGain, 0.0);
      expect(activity.totalElevationGain, isA<double>());
    });

    test('coerces a zero-valued calories/max_speed pair to double', () {
      final activity =
          DetailedActivity.fromJson(_loadFixture('run_manual_treadmill'));

      expect(activity.calories, 0.0);
      expect(activity.maxSpeed, 0.0);
    });
  });

  group('createSummaryActivity against fixture payloads', () {
    test('finds the fastest qualifying window in a typical 5K', () {
      final activity =
          DetailedActivity.fromJson(_loadFixture('run_5k_typical'));

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance,
          closeTo(stravaFilterMinDistance + 100, 300));
      expect(summary.fastestSplit.elapsedTime, greaterThan(0));
    });

    test('finds a qualifying window inside a 50K ultra', () {
      final activity =
          DetailedActivity.fromJson(_loadFixture('run_ultra_multilap'));

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, greaterThan(stravaFilterMinDistance));
      expect(summary.fastestSplit.distance, lessThan(stravaFilterMaxDistance));
    });

    test('finds no qualifying window in a sub-5K run', () {
      final activity = DetailedActivity.fromJson(_loadFixture('run_sub_5k'));

      final summary = resource.createSummaryActivity(activity);

      expect(summary.fastestSplit.distance, 0);
    });
  });

  group('isEligibleWeeklyRun', () {
    SummaryActivity summaryFromFixture(String name) =>
        SummaryActivity.fromJson(_loadFixture(name));

    test('accepts a typical geolocated, non-manual 5K run', () {
      expect(isEligibleWeeklyRun(summaryFromFixture('run_5k_typical')), isTrue);
    });

    test('rejects a manual treadmill run with no GPS', () {
      expect(
          isEligibleWeeklyRun(summaryFromFixture('run_manual_treadmill')),
          isFalse);
    });

    test('rejects a run with empty start/end latlng', () {
      expect(isEligibleWeeklyRun(summaryFromFixture('run_no_gps')), isFalse);
    });

    test('rejects a run under the minimum distance floor', () {
      expect(isEligibleWeeklyRun(summaryFromFixture('run_sub_5k')), isFalse);
    });

    test('rejects a non-run activity type', () {
      expect(isEligibleWeeklyRun(summaryFromFixture('ride_not_a_run')), isFalse);
    });

    test('accepts a qualifying ultra run', () {
      expect(
          isEligibleWeeklyRun(summaryFromFixture('run_ultra_multilap')),
          isTrue);
    });
  });
}
