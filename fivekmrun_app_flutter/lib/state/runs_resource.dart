import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

class RunsResource extends ChangeNotifier {
  Run _bestRun;
  Run _lastRun;

  Run get bestRun {
    return _bestRun;
  }

  Run get lastRun {
    return _lastRun;
  }

  List<Run> value;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  clear() {
    this.value = null;
    this.loading = false;
    this._bestRun = null;
    this._lastRun = null;
  }

  Future<List<Run>> getByUserId(int userId) async {
    this.loading = true;


    List<Run> runs = await this.retrieve5kmRuns(userId) ?? new List<Run>();
    List<Run> selfieRuns = await this.retrieveSelfieRuns(userId);
    runs.addAll(selfieRuns.where((r) => r.timeInSeconds != null));

    this._processRuns(runs);

    this.value = runs;
    this.loading = false;
    return runs;
  }

  retrieve5kmRuns(int userId) async {
        http.Response response =
        await http.get("${constants.runsEndpointUrl}$userId");
      if (response.statusCode != 200 ||
          response.headers["content-type"] != "application/json;charset=utf-8;") {
        this.loading = false;
        //TODO: Fix this when endpoint behaves properly
        this.value = new List<Run>();
        return null;
      }

      String body = utf8.decode(response.bodyBytes);
      return Run.listFromJson(jsonDecode(body));
  }

  retrieveSelfieRuns(int userId) async {
      http.Response response =
        await http.get("https://5kmrun.bg/api/selfie/user/$userId");
      if (response.statusCode != 200 ||
          response.headers["content-type"] != "application/json;charset=utf-8;") {
        this.loading = false;
        //TODO: Fix this when endpoint behaves properly
        this.value = new List<Run>();
        return null;
      }

      String body = utf8.decode(response.bodyBytes);
      return Run.selfieListFromJson(jsonDecode(body));
  }

  void _processRuns(List<Run> runs) {
    if (runs == null || runs.length == 0) {
      this._bestRun = null;
      this._lastRun = null;
      return;
    }

    runs.sort((r1, r2) => r2.date.compareTo(r1.date));

    this._lastRun = runs.first;
    this._bestRun =
        runs.reduce((a, b) => (a.timeInSeconds ?? 0) < (b.timeInSeconds ?? 0) ? a : b);

    for (var i = 0; i < runs.length; i++) {
      final r = runs[i];
      runs[i].differenceFromBest =
          r.timeInSeconds - this._bestRun.timeInSeconds;

      if (i < runs.length - 1) {
        r.differenceFromPrevious = r.timeInSeconds - runs[i + 1].timeInSeconds;
      }
    }
  }
}
