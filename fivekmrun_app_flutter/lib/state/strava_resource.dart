import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/strava_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:strava_flutter/domain/model/model_authentication_response.dart';
import 'package:strava_flutter/domain/model/model_authentication_scopes.dart';
import 'package:strava_flutter/domain/model/model_detailed_activity.dart';
import 'package:strava_flutter/domain/model/model_detailed_athlete.dart';
import 'package:strava_flutter/strava_client.dart';

typedef StravaCallback<T> = Future<T> Function(StravaClient strava);

class StravaResource extends ChangeNotifier {
  static StravaClient? strava;

  Future<T> _withStrava<T>(StravaCallback<T> fn) async {
    if (strava == null) {
      strava = StravaClient(clientId: stravaClientId, secret: stravaSecret);
    }
    try {
      return await fn(strava!);
    } finally {}
  }

  Future<bool> isAuthenticated() async {
    return _withStrava((strava) async {
      final token = await strava.getStravaAuthToken();
      final hasValidToken = token != null &&
          token.accessToken != "null" &&
          !this._isTokenExpired(token);

      if (!hasValidToken) {
        return false;
      }

      final assureAuthenticated = this._assureAuthenticated(strava);

      return assureAuthenticated;
    });
  }

  Future<bool> _assureAuthenticated(StravaClient strava) async {
    DetailedAthlete athlete;
    try {
      athlete = await strava.athletes.getAuthenticatedAthlete();
    } catch (e) {
      this.deAuthenticate();
      this.authenticate();
      athlete = await strava.athletes.getAuthenticatedAthlete();
    }

    FirebaseCrashlytics.instance.setCustomKey("stravaUserID", athlete.id);
    FirebaseCrashlytics.instance
        .log("Strava get activities - atheleteID: ${athlete.id}");
    return true;
  }

  Future<bool> authenticate() async {
    FirebaseCrashlytics.instance.log("Strava authenticate started");

    return _withStrava((strava) async {
      final scopes = [
        AuthenticationScope.read_all,
        AuthenticationScope.activity_read_all,
        AuthenticationScope.profile_read_all
      ];
      final isAuthOk = await strava.authentication
          .authenticate(scopes: scopes, redirectUrl: "fivekmrun://redirect/")
          .then((t) => true)
          .onError((error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
        strava.authentication.deAuthorize();
        return false;
      });

      FirebaseCrashlytics.instance.log("Strava authenticate result: $isAuthOk");

      return isAuthOk;
    });
  }

  void deAuthenticate() async {
    return _withStrava((strava) async {
      FirebaseCrashlytics.instance.log("Strava deAuthenticate");
      FirebaseCrashlytics.instance.setCustomKey("stravaUserID", -1);

      await strava.authentication.deAuthorize();
    });
  }

  StravaSummaryRun createSummaryActivity(DetailedActivity activity) {
    double bestDistance = 0;
    double bestTime = 999999;

    var splits = activity.splitsMetric!;

    for (var startIdx = 0; startIdx < splits.length; startIdx++) {
      int endIdx = startIdx;
      double dist = 0;
      double time = 0;

      while (endIdx < splits.length && dist < stravaFilterMinDistance) {
        dist += splits[endIdx].distance!;
        time += splits[endIdx].elapsedTime!;
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

  Future<List<StravaSummaryRun>?> getThisWeekActivities() async {
    FirebaseCrashlytics.instance.log("Strava get activities");

    return _withStrava((strava) async {
      final authOK = await this.authenticate();
      if (!authOK) {
        FirebaseCrashlytics.instance
            .log("Strava get activities - authOK: false");
        return null;
      }

      final isReallyAuthenticated = await this._assureAuthenticated(strava);
      if (!isReallyAuthenticated) {
        // Return null in case of error
        return null;
      }

      final now = DateTime.now();
      DateTime before = now;
      DateTime after = now.subtract(Duration(
          //days: 90,
          days: now.weekday - 1,
          hours: now.hour,
          minutes: now.minute,
          seconds: now.second));
      try {
        final activities = await strava.activities
            .listLoggedInAthleteActivities(before, after, 1, 100);

        FirebaseCrashlytics.instance
            .log("Strava get activities results: ${activities.length}");

        final runActivites = await Future.wait(activities
            .where((a) =>
                a.type!.toLowerCase() == "run" &&
                a.distance! >= stravaFilterMinDistance &&
                a.startLatlng != null &&
                a.endLatlng != null &&
                a.manual == false &&
                a.map != null)
            .map((a) => strava.activities.getActivity(a.id!)));

        FirebaseCrashlytics.instance.log(
            "Strava get filtered activities results: ${runActivites.length}");

        final summaryActivites = runActivites
            .where((a) => a.manual == false)
            .map((a) => createSummaryActivity(a))
            // filter again in case we didn't find the proper split
            .where((s) => s.fastestSplit.distance > stravaFilterMinDistance)
            .toList();

        return summaryActivites;
      } on Exception catch (e) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      }
    });
  }

  bool _isTokenExpired(TokenResponse? token) {
    // when it is the first run or after a deAuthotrize
    if (token == null) {
      return false;
    }

    if (token.expiresAt < DateTime.now().millisecondsSinceEpoch / 1000) {
      return true;
    } else {
      return false;
    }
  }
}
