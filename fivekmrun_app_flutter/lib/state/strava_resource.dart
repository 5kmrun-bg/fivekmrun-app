import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';
import 'package:fivekmrun_flutter/state/strava_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:strava_client/strava_client.dart';

typedef StravaCallback<T> = Future<T> Function(StravaClient strava);

/// Describes an error thrown by the strava_client package for logging.
///
/// [Fault] (the package's error model for a failed API call) has no
/// `toString()` override, so an uncaught one only ever logs as the useless
/// "Instance of 'Fault'". This surfaces the actual message/error codes
/// instead, falling back to `error.toString()` for anything else.
String describeStravaError(Object error) {
  if (error is Fault) {
    final codes = (error.errors ?? [])
        .map((e) => [e.resource, e.field, e.code]
            .where((part) => part != null)
            .join(":"))
        .where((s) => s.isNotEmpty)
        .join(", ");
    final message = error.message ?? "no message";
    return codes.isEmpty ? message : "$message ($codes)";
  }
  return error.toString();
}

/// Whether a summary activity qualifies as a run worth fetching full details
/// for: a non-manual run of at least [stravaFilterMinDistance] with both
/// endpoints geolocated.
bool isEligibleWeeklyRun(SummaryActivity activity) {
  return activity.type!.toLowerCase() == "run" &&
      activity.distance! >= stravaFilterMinDistance &&
      (activity.startLatlng?.isNotEmpty ?? false) &&
      (activity.endLatlng?.isNotEmpty ?? false) &&
      activity.manual == false;
}

/// Reports an error/stackTrace pair with a human-readable [reason], e.g. to
/// Crashlytics. Injected so callers can be unit-tested without Firebase.
typedef StravaErrorReporter = void Function(
    Object error, StackTrace stackTrace, String reason);

void _reportStravaErrorToCrashlytics(
    Object error, StackTrace stackTrace, String reason) {
  FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: reason);
}

/// Fetches the authenticated athlete via [getAthlete], re-authenticating and
/// retrying once if the first attempt fails (e.g. an expired/revoked token).
///
/// Both attempts are guarded: if [getAthlete] fails again after
/// [reAuthenticate] runs, this returns `null` instead of letting the second
/// failure escape unhandled, and each failure is reported via [reportError]
/// with the underlying message rather than a bare "Instance of 'Fault'".
Future<DetailedAthlete?> fetchAuthenticatedAthleteWithRetry(
  Future<DetailedAthlete> Function() getAthlete,
  Future<void> Function() reAuthenticate, {
  StravaErrorReporter reportError = _reportStravaErrorToCrashlytics,
}) async {
  try {
    return await getAthlete();
  } catch (error, stackTrace) {
    reportError(error, stackTrace,
        "Strava getAuthenticatedAthlete failed: ${describeStravaError(error)}");
  }

  await reAuthenticate();

  try {
    return await getAthlete();
  } catch (error, stackTrace) {
    reportError(error, stackTrace,
        "Strava getAuthenticatedAthlete retry failed: ${describeStravaError(error)}");
    return null;
  }
}

class StravaResource extends ChangeNotifier {
  static StravaClient? strava;

  Future<T> _withStrava<T>(StravaCallback<T> fn) async {
    strava ??= StravaClient(clientId: stravaClientId, secret: stravaSecret);
    try {
      return await fn(strava!);
    } finally {}
  }

  Future<bool> isAuthenticated() async {
    return _withStrava((strava) async {
      final token = await strava.getStravaAuthToken();
      final hasValidToken = token != null &&
          token.accessToken != "null" &&
          !_isTokenExpired(token);

      if (!hasValidToken) {
        return false;
      }

      final assureAuthenticated = _assureAuthenticated(strava);

      return assureAuthenticated;
    });
  }

  Future<bool> _assureAuthenticated(StravaClient strava) async {
    final athlete = await fetchAuthenticatedAthleteWithRetry(
      strava.athletes.getAuthenticatedAthlete,
      () async {
        await deAuthenticate();
        await authenticate();
      },
    );

    if (athlete == null) {
      return false;
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
          .authenticate(
              scopes: scopes,
              redirectUrl: "fivekmrun://redirect/",
              callbackUrlScheme: "fivekmrun")
          .then((t) => true)
          .onError((error, stackTrace) async {
        FirebaseCrashlytics.instance.recordError(error, stackTrace,
            reason: "Strava authenticate failed: "
                "${describeStravaError(error!)}");
        try {
          await strava.authentication.deAuthorize();
        } catch (deAuthorizeError, deAuthorizeStackTrace) {
          FirebaseCrashlytics.instance.recordError(
              deAuthorizeError, deAuthorizeStackTrace,
              reason: "Strava deAuthorize after failed authenticate failed: "
                  "${describeStravaError(deAuthorizeError)}");
        }
        return false;
      });

      FirebaseCrashlytics.instance.log("Strava authenticate result: $isAuthOk");

      return isAuthOk;
    });
  }

  Future<void> deAuthenticate() async {
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
      final authOK = await authenticate();
      if (!authOK) {
        FirebaseCrashlytics.instance
            .log("Strava get activities - authOK: false");
        return null;
      }

      final isReallyAuthenticated = await _assureAuthenticated(strava);
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
            .where(isEligibleWeeklyRun)
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
      return null;
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
