import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:flutter/material.dart';
import 'package:strava_flutter/Models/activity.dart';
import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/Models/token.dart';
import 'package:strava_flutter/strava.dart';

typedef StravaCallback<T> = Future<T> Function(Strava strava);

class StravaResource extends ChangeNotifier {
  // Strava strava = Strava(true, stravaSecret);

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
      return token != null &&
          token.accessToken != null &&
          token.accessToken != "null" &&
          !this._isTokenExpired(token);
    });
  }

  Future<bool> authenticate() async {
    return _withStrava((strava) async {
      bool isAuthOk = await strava.oauth(stravaClientId,
          'read_all,activity:read_all,profile:read_all', stravaSecret, 'auto');
      return isAuthOk;
    });
  }

  Future<Fault> deAuthenticate() async {
    return _withStrava((strava) async {
      Fault result = await strava.deAuthorize();
      return result;
    });
  }

  Future<List<DetailedActivity>> getThisWeekActivities() async {
    return _withStrava((strava) async {
      final authOK = await this.authenticate();
      if (!authOK) {
        // TODO: should we throw here?
        return [];
      }
      final now = DateTime.now();

      int before = now
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;
      int after = now.subtract(Duration(days: now.weekday - 1, hours: now.hour, minutes: now.minute, seconds: now.second))
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;

      final activities = await strava.getLoggedInAthleteActivities(before, after);

      // TODO: Additional filters (distance)
      final runActivites = await Future.wait(activities
          .where((a) => a.type == ActivityType.Run && a.distance >= stravaFilterMinDistance && a.distance <= stravaFilterMaxDistance)
          .map((a) => strava.getActivityById(a.id.toString())));

      return runActivites;
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
