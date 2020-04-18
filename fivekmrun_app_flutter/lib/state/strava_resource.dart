import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:flutter/material.dart';
import 'package:strava_flutter/Models/activity.dart';
import 'package:strava_flutter/Models/fault.dart';
import 'package:strava_flutter/Models/token.dart';
import 'package:strava_flutter/strava.dart';

class StravaResource extends ChangeNotifier {
  Strava strava = Strava(true, stravaSecret);

  Future<bool> isAuthenticated() async {
    var token = await strava.getStoredToken();
    return token != null &&
        token.accessToken != null &&
        token.accessToken != "null" &&
        !this._isTokenExpired(token);
  }

  Future<bool> authenticate() async {
    bool isAuthOk = await strava.oauth(stravaClientId,
        'read_all,activity:read_all,profile:read_all', stravaSecret, 'auto');
    return isAuthOk;
  }

  Future<Fault> deAuthenticate() async {
    Fault result = await strava.deAuthorize();
    print(result.statusCode);
    print(result.message);
    return result;
  }

  Future<List<DetailedActivity>> getThisWeekActivities() async {
    var authOK = await this.authenticate();
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

    var activities = await strava.getLoggedInAthleteActivities(before, after);

    // TODO: Additional filters (distance)
    var runActivites = await Future.wait(activities
        .where((a) => a.type == ActivityType.Run)
        .map(this._getActivityById));

    return runActivites;
  }

  Future<DetailedActivity> _getActivityById(SummaryActivity activity) async {
    var result = await strava.getActivityById(activity.id.toString());

    return result;
  }

  @override
  void dispose() {
    if (strava != null) {
      strava.dispose();
      strava = null;
    }

    super.dispose();
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
