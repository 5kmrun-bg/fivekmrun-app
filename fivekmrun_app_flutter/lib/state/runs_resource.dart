import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

/// The outcome of loading one run source: the runs it returned, or the error
/// that stopped it. Exactly one of the two is meaningful.
class _SourceResult {
  final List<Run> runs;
  final Object? failure;

  const _SourceResult(this.runs, this.failure);
}

class RunsResource extends ChangeNotifier {
  /// Injectable for tests; defaults to a real client in production.
  final http.Client _client;

  RunsResource({http.Client? client}) : _client = client ?? http.Client();

  Run? _bestOfficialRun;
  Run? _lastOfficialRun;

  Run? get bestOfficialRun {
    return _bestOfficialRun;
  }

  Run? get lastOfficialRun {
    return _lastOfficialRun;
  }

  Run? _bestSelfieRun;
  Run? _lastSelfieRun;

  Run? get bestSelfieRun {
    return _bestSelfieRun;
  }

  Run? get lastSelfieRun {
    return _lastSelfieRun;
  }

  List<Run>? value;

  bool _loading = true;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  clear() {
    this.value = null;
    this.loading = true;
    this._bestOfficialRun = null;
    this._lastOfficialRun = null;
  }

  /// Fetches the user's runs from each source and replaces [value].
  ///
  /// The sources are independent. `5kmrun/user/<id>` does not answer with an
  /// empty array for a user with no official results — it errors server-side
  /// and redirects to an HTML page. Loading them in one `try` meant that page
  /// aborted the whole load, so every user whose history is selfie-only saw an
  /// empty runs list despite having hundreds of runs. A source that fails now
  /// contributes nothing and the others still load.
  ///
  /// If *every* source fails the previously loaded runs are kept and the error
  /// is rethrown — an unreachable server must not look the same as "this user
  /// has never run". See [refreshAllData].
  ///
  /// A partial failure does replace [value] with what did load, so a source
  /// that is down drops its runs from the list until the next refresh. That is
  /// deliberate: showing the rest beats showing nothing, and it self-heals.
  Future<List<Run>> getByUserId(int? userId) async {
    if (userId == null) {
      return this.value ?? <Run>[];
    }

    final official = await _tryRetrieve(() => this.retrieve5kmRuns(userId));
    final selfie = await _tryRetrieve(() => this.retrieveSelfieRuns(userId));
    final xl = await _tryRetrieve(() => this.retrieveXLRuns(userId));

    // Only the two mandatory sources decide this. [retrieveXLRuns] already
    // answers "no XL runs" for its own error page, so it succeeds with an
    // empty list for nearly every user — letting it vote here would mean a
    // total outage of the other two still looked like "no runs".
    if (official.failure != null && selfie.failure != null) {
      this.loading = false;
      throw official.failure!;
    }

    final List<Run> runs = <Run>[
      ...official.runs,
      ...selfie.runs.where((r) => r.timeInSeconds != null),
      ...xl.runs.where((r) => r.timeInSeconds != null),
    ];

    this._processRuns(runs);

    this.value = runs;
    this.loading = false;
    return runs;
  }

  /// Runs [retrieve], turning a failure into an empty result that records the
  /// error instead of propagating it.
  Future<_SourceResult> _tryRetrieve(
      Future<List<Run>> Function() retrieve) async {
    try {
      return _SourceResult(await retrieve(), null);
    } catch (error) {
      return _SourceResult(const <Run>[], error);
    }
  }

  Future<List<Run>> retrieve5kmRuns(int? userId) async {
    final http.Response response =
        await _client.get(Uri.parse("${constants.runsEndpointUrl}$userId"));
    ensureJsonResponse(response, "5km runs");

    String body = utf8.decode(response.bodyBytes);
    return Run.listFromJson(jsonDecode(body));
  }

  Future<List<Run>> retrieveSelfieRuns(int? userId) async {
    final http.Response response =
        await _client.get(Uri.parse("https://5kmrun.bg/api/selfie/user/$userId"));
    ensureJsonResponse(response, "selfie runs");

    String body = utf8.decode(response.bodyBytes);
    return Run.selfieListFromJson(jsonDecode(body));
  }

  /// Unlike the other two endpoints, xlrun/user/<id> answers with a non-JSON
  /// error page (not an empty array) for the vast majority of users who have
  /// no XL history — so, unlike [retrieve5kmRuns]/[retrieveSelfieRuns], that
  /// response is treated as "no XL runs" rather than a fetch failure. Letting
  /// it throw would break the whole runs list for every non-XL user.
  Future<List<Run>> retrieveXLRuns(int? userId) async {
    final http.Response response =
        await _client.get(Uri.parse("${constants.xlUserEndpointUrl}$userId"));

    if (!isJsonResponse(response.statusCode, response.headers["content-type"])) {
      return <Run>[];
    }

    String body = utf8.decode(response.bodyBytes);
    return Run.listFromXLUserJson(jsonDecode(body));
  }

  void _processRuns(List<Run> runs) {
    if (runs.length == 0) {
      this._bestOfficialRun = null;
      this._lastOfficialRun = null;
      this._bestSelfieRun = null;
      this._lastSelfieRun = null;
      return;
    }

    runs.sort((r1, r2) => r2.date?.compareTo(r1.date!) ?? 0);

    final officialRuns = runs.where((r) => r.runType == RunType.official);
    if (officialRuns.length > 0) {
      this._lastOfficialRun = officialRuns.first;
      this._bestOfficialRun = officialRuns.reduce((a, b) =>
          (a.timeInSeconds ?? 0) < (b.timeInSeconds ?? 0) ? a : b);
      //Function.apply((r) => r.differenceFromBest = r.timeInSeconds - this._bestOfficialRun.timeInSeconds, runs.where((r) => !r.isSelfie).toList());
    }

    final selfieRuns = runs.where((r) => r.runType == RunType.selfie);
    if (selfieRuns.length > 0) {
      this._lastSelfieRun = selfieRuns.first;
      this._bestSelfieRun = selfieRuns.reduce(
          (a, b) => (a.timeInSeconds ?? 0) < (b.timeInSeconds ?? 0) ? a : b);
      //Function.apply((r) => r.differenceFromBest = r.timeInSeconds - this._bestSelfieRun.timeInSeconds, runs.where((r) => r.isSelfie).toList());
    }

    // for (var i = 0; i < runs.length; i++) {
    //   final r = runs[i];
    //   runs[i].differenceFromBest =
    //       r.timeInSeconds - this._bestOfficialRun.timeInSeconds;

    //   if (i < runs.length - 1) {
    //     r.differenceFromPrevious = r.timeInSeconds - runs[i + 1].timeInSeconds;
    //   }
    // }
  }
}
