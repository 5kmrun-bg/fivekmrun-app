import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';

/// The soonest upcoming XL event, or null if none is scheduled. Today's
/// event still counts as upcoming — it's compared by day, not by timestamp,
/// because the event's start time lives in a separate `time` string.
XLEvent? nextUpcomingXLEvent(List<Event> events, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);

  final upcoming = events
      .whereType<XLEvent>()
      .where((e) => !e.date.isBefore(startOfToday))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return upcoming.isEmpty ? null : upcoming.first;
}

/// Aggregate XLrun engagement stats for the profile page, derived from the
/// user's already-fetched runs list (RunsResource) rather than a second
/// fetch against `xlrun/user/<id>` — RunsResource already hits that endpoint
/// to build "Твоите бягания" (#179), so calling it again here would just
/// duplicate the same request for data already in memory.
///
/// Elevation isn't included: the endpoint carries no elevation field
/// anywhere (confirmed in #178), so it isn't buildable without a backend
/// addition. "Best XL finish time" is also left out deliberately — XL
/// events vary in distance, so a single fastest raw time isn't a meaningful
/// "best" across them the way it is for the fixed-distance official/selfie
/// stats, and there's no reliable way to derive whatever normalization the
/// backend's own `min`/`avg`/`max` aggregates use from the runs list alone.
class XLStats {
  final int runsThisYear;
  final int runsAllTime;
  final int? distanceThisYearMeters;
  final int? totalDistanceMeters;
  final Run? mostRecentRun;

  const XLStats({
    required this.runsThisYear,
    required this.runsAllTime,
    required this.distanceThisYearMeters,
    required this.totalDistanceMeters,
    required this.mostRecentRun,
  });

  /// Returns null if the user has no XL history, so callers can skip
  /// rendering the stat card entirely rather than showing all-zero stats.
  static XLStats? fromRuns(List<Run> allRuns) {
    final xlRuns = allRuns.where((r) => r.runType == RunType.xl).toList();
    if (xlRuns.isEmpty) {
      return null;
    }

    xlRuns.sort(
        (a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

    final currentYear = DateTime.now().year;
    final thisYearRuns =
        xlRuns.where((r) => r.date?.year == currentYear).toList();

    // Only runs whose distance was successfully parsed out of "n_name"
    // contribute — an unparseable name means an unknown distance, not a
    // zero one, so it's excluded rather than treated as 0km.
    int? sumDistance(List<Run> runs) {
      final parsed = runs.map((r) => r.distance).whereType<int>();
      return parsed.isEmpty ? null : parsed.reduce((a, b) => a + b);
    }

    return XLStats(
      runsThisYear: thisYearRuns.length,
      runsAllTime: xlRuns.length,
      distanceThisYearMeters: sumDistance(thisYearRuns),
      totalDistanceMeters: sumDistance(xlRuns),
      mostRecentRun: xlRuns.first,
    );
  }
}
