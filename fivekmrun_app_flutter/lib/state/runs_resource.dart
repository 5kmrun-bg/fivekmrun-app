import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

class RunsResource extends ChangeNotifier {
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

  /// Fetches the user's runs and replaces [value] on success.
  ///
  /// If the fetch fails the previously loaded runs are kept — an unreachable
  /// server must not look the same as "this user has never run". The error is
  /// rethrown so callers can react; see [refreshAllData].
  Future<List<Run>> getByUserId(int? userId) async {
    if (userId == null) {
      return this.value ?? <Run>[];
    }

    final List<Run> runs;
    try {
      runs = await this.retrieve5kmRuns(userId);
      final List<Run> selfieRuns = await this.retrieveSelfieRuns(userId);
      runs.addAll(selfieRuns.where((r) => r.timeInSeconds != null));
      final List<Run> xlRuns = await this.retrieveXLRuns(userId);
      runs.addAll(xlRuns.where((r) => r.timeInSeconds != null));
    } catch (_) {
      this.loading = false;
      rethrow;
    }

    this._processRuns(runs);

    this.value = runs;
    this.loading = false;
    return runs;
  }

  Future<List<Run>> retrieve5kmRuns(int? userId) async {
    final http.Response response =
        await http.get(Uri.parse("${constants.runsEndpointUrl}$userId"));
    ensureJsonResponse(response, "5km runs");

    String body = utf8.decode(response.bodyBytes);
    return Run.listFromJson(jsonDecode(body));
  }

  Future<List<Run>> retrieveSelfieRuns(int? userId) async {
    final http.Response response =
        await http.get(Uri.parse("https://5kmrun.bg/api/selfie/user/$userId"));
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
    final http.Response response = await http
        .get(Uri.parse("${constants.xlUserEndpointUrl}$userId"));

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
