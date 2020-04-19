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
    Strava strava = Strava(true, stravaSecret);
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

      int before = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;
      int after = DateTime.now()
          .subtract(new Duration(days: 7))
          .difference(DateTime.fromMillisecondsSinceEpoch(0))
          .inSeconds;

      final activities = await strava.getLoggedInAthleteActivities(before, after);

      // TODO: Additional filters (distance)
      final runActivites = await Future.wait(activities
          .where((a) => a.type == ActivityType.Run)
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
