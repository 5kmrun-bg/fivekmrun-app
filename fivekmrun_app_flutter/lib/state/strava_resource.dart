import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/strava_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:strava_flutter/Models/activity.dart';
import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/Models/token.dart';
import 'package:strava_flutter/strava.dart';

typedef StravaCallback<T> = Future<T> Function(Strava strava);

class StravaResource extends ChangeNotifier {
  Future<T> _withStrava<T>(StravaCallback<T> fn) async {
    Strava strava = Strava(false, stravaSecret);
    try {
      return await fn(strava);
    } finally {
      strava.dispose();
    }
  }

  Future<bool> isAuthenticated() async {
    return _withStrava((strava) async {
      final token = await strava.getStoredToken();
      final hasValidToken = token != null &&
          token.accessToken != null &&
          token.accessToken != "null" &&
          !this._isTokenExpired(token);

      if (!hasValidToken) {
        return false;
      }

      final assureAuthenticated = this._assureAuthenticated(strava);

      return assureAuthenticated;
    });
  }

  Future<bool> _assureAuthenticated(Strava strava) async {
    final athlete = await strava.getLoggedInAthlete();
    if (athlete == null || athlete.id == null) {
      final message =
          "_assureAuthenticated - cannot get athlete fault: [${athlete?.fault?.statusCode}] ${athlete?.fault?.message} - will deAuthenticate";
      Crashlytics.instance.recordError(message, StackTrace.current);

      await this.deAuthenticate();

      return false;
    } else {
      Crashlytics.instance.setInt("stravaUserID", athlete.id);
      Crashlytics.instance
          .log("Strava get activities - atheleteID: ${athlete.id}");
      return true;
    }
  }

  Future<bool> authenticate() async {
    Crashlytics.instance.log("Strava authenticate started");

    return _withStrava((strava) async {
      bool isAuthOk = await strava.oauth(stravaClientId,
          'read_all,activity:read_all,profile:read_all', stravaSecret, 'auto');

      Crashlytics.instance.log("Strava authenticate result: $isAuthOk");

      return isAuthOk;
    });
  }

  Future<Fault> deAuthenticate() async {
    return _withStrava((strava) async {
      Crashlytics.instance.log("Strava deAuthenticate");
      Crashlytics.instance.setInt("stravaUserID", null);

      Fault result = await strava.deAuthorize();

      Crashlytics.instance.log(
          "Strava deAuthenticate result: [${result?.statusCode}]: ${result?.message} ");

      return result;
    });
  }

  StravaSummaryRun createSummaryActivity(DetailedActivity activity) {
    double bestDistance = 0;
    int bestTime = 999999;

    var splits = activity.splitsMetric;

    for (var startIdx = 0; startIdx < splits.length; startIdx++) {
      int endIdx = startIdx;
      double dist = 0;
      int time = 0;

      while (endIdx < splits.length && dist < stravaFilterMinDistance) {
        dist += splits[endIdx].distance;
        time += splits[endIdx].elapsedTime;
        endIdx++;
      }

      if (dist > stravaFilterMinDistance &&
          dist < stravaFilterMaxDistance &&
          time < bestTime) {
        bestDistance = dist;
        bestTime = time;
      }
    }

    FastestSplitSummary summary =
        FastestSplitSummary(elapsedTime: bestTime, distance: bestDistance);
    return StravaSummaryRun(detailedActivity: activity, fastestSplit: summary);
  }

  Future<List<StravaSummaryRun>> getThisWeekActivities() async {
    Crashlytics.instance.log("Strava get activities");

    return _withStrava((strava) async {
      final authOK = await this.authenticate();
      if (!authOK) {
        Crashlytics.instance.log("Strava get activities - authOK: false");
        return null;
      }

      final isReallyAuthenticated = await this._assureAuthenticated(strava);
      if (!isReallyAuthenticated) {
        // Return null in case of error
        return null;
      }

      final now = DateTime.now();
      int before =
          now.difference(DateTime.fromMillisecondsSinceEpoch(0)).inSeconds;
      int after = now
          .subtract(Duration(
              days: now.weekday - 1,
              hours: now.hour,
              minutes: now.minute,
              seconds: now.second))
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;
      try {
        final activities =
            await strava.getLoggedInAthleteActivities(before, after);

        if (activities == null) {
          Crashlytics.instance.log("Strava get activities results: null");

          return [];
        }

        Crashlytics.instance
            .log("Strava get activities results: ${activities.length}");

        final runActivites = await Future.wait(activities
            .where((a) =>
                    a.type == ActivityType.Run &&
                    a.distance >= stravaFilterMinDistance
                )
            .map((a) => strava.getActivityById(a.id.toString())));

        Crashlytics.instance.log(
            "Strava get filtered activities results: ${runActivites.length}");

        final summaryActivites = runActivites
            .map((a) => createSummaryActivity(a))
            // filter again in case we didn't find the proper split
            .where((s) => s.fastestSplit.distance > stravaFilterMinDistance)
            .toList();

        return summaryActivites;
      } on Exception catch (e) {
        Crashlytics.instance.recordError(e, StackTrace.current);
      }
    });
  }

  bool _isTokenExpired(Token token) {
    // when it is the first run or after a deAuthotrize
    if (token.expiresAt == null) {
      return false;
    }

    if (token.expiresAt < DateTime.now().millisecondsSinceEpoch / 1000) {
      return true;
    } else {
      return false;
    }
  }
}
