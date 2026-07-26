import 'package:fivekmrun_flutter/state/run_model.dart';

/// Aggregate KidsRun engagement stats for the profile page, derived from the
/// user's already-fetched runs list (RunsResource) rather than a second
/// fetch against kidsrun/user/<id> — RunsResource already hits that endpoint
/// to build "Твоите бягания" (#188), so calling it again here would just
/// duplicate the same request for data already in memory. Mirrors XLStats
/// (#178), with one difference: KidsRun events are all a fixed ~2km
/// (Run.kidsDistanceMeters), so unlike XL, total distance and a single
/// "best time" are both directly comparable across every Kids run and are
/// included here.
class KidsStats {
  final int runsThisYear;
  final int runsAllTime;
  final int totalDistanceMeters;
  final Run? mostRecentRun;
  final Run? bestRun;

  const KidsStats({
    required this.runsThisYear,
    required this.runsAllTime,
    required this.totalDistanceMeters,
    required this.mostRecentRun,
    required this.bestRun,
  });

  /// Returns null if the user has no Kids history, so callers can skip
  /// rendering the stat card entirely rather than showing all-zero stats.
  static KidsStats? fromRuns(List<Run> allRuns) {
    final kidsRuns = allRuns.where((r) => r.runType == RunType.kids).toList();
    if (kidsRuns.isEmpty) {
      return null;
    }

    kidsRuns.sort(
        (a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

    final currentYear = DateTime.now().year;
    final runsThisYear =
        kidsRuns.where((r) => r.date?.year == currentYear).length;

    // Every Kids run is the same fixed distance, so this is a plain sum —
    // no unparseable-name caveat like XL's per-run distance parsing.
    final totalDistanceMeters =
        kidsRuns.fold<int>(0, (sum, r) => sum + (r.distance ?? 0));

    final Run bestRun = kidsRuns.reduce((a, b) =>
        (a.timeInSeconds ?? 1 << 30) < (b.timeInSeconds ?? 1 << 30) ? a : b);

    return KidsStats(
      runsThisYear: runsThisYear,
      runsAllTime: kidsRuns.length,
      totalDistanceMeters: totalDistanceMeters,
      mostRecentRun: kidsRuns.first,
      bestRun: bestRun,
    );
  }
}
