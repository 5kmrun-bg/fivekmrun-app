import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reloads the profile, runs and events resources.
///
/// Backs the pull-to-refresh gesture on the profile, runs and events tabs, so a
/// refresh triggered on any of them updates the data on all three. The offline
/// chart keeps its own data and is not refreshed here.
///
/// Never completes with an error: `RefreshIndicator` attaches no error handler
/// to the future it gets back, so a rejection here would surface as an
/// unhandled exception. Failures are reported to Crashlytics instead, and each
/// resource keeps the data it already had.
Future<void> refreshAllData(BuildContext context) async {
  final userId =
      Provider.of<AuthenticationResource>(context, listen: false).getUserId();

  final userRes = Provider.of<UserResource>(context, listen: false);
  final runsRes = Provider.of<RunsResource>(context, listen: false);
  final futureEventsRes =
      Provider.of<AllFutureEventsResource>(context, listen: false);
  final pastEventsRes = Provider.of<PastEventsResource>(context, listen: false);

  // eagerError: false — one unreachable endpoint shouldn't abandon the others.
  await Future.wait(
    <Future<dynamic>>[
      if (userId != null)
        reportOnFailure(userRes.getById(userId, true), "user"),
      if (userId != null) reportOnFailure(runsRes.getByUserId(userId), "runs"),
      reportOnFailure(futureEventsRes.getAll(), "future events"),
      reportOnFailure(pastEventsRes.getAll(), "past events"),
    ],
    eagerError: false,
  );
}

/// Awaits [future], swallowing any failure after reporting it to Crashlytics.
///
/// Use for data loads whose failure shouldn't reach the user as an error: the
/// resources keep their previous value, so there is nothing to recover from.
Future<void> reportOnFailure(Future<dynamic> future, String label) async {
  try {
    await future;
  } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: "refresh failed: $label",
      fatal: false,
    );
  }
}

/// Wraps a centered [child] in an always-scrollable viewport that fills the
/// available space, so the pull-to-refresh gesture still works while a screen
/// is loading or showing an empty-state message.
Widget refreshableMessage(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(child: child),
      ),
    ),
  );
}
