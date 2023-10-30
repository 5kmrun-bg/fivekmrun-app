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

  Future<List<Run>> getByUserId(int? userId) async {
    List<Run> runs = (await this.retrieve5kmRuns(userId));
    List<Run> selfieRuns = await this.retrieveSelfieRuns(userId);
    runs.addAll(selfieRuns.where((r) => r.timeInSeconds != null));

    print("COUNT RUNS:" + runs.length.toString());

    this._processRuns(runs);

    this.value = runs;
    this.loading = false;
    return runs;
  }

  Future<List<Run>> retrieve5kmRuns(int? userId) async {
    http.Response response =
        await http.get(Uri.parse("${constants.runsEndpointUrl}$userId"));
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      print('hello');
      //TODO: Fix this when endpoint behaves properly

      return [];
    }

    String body = utf8.decode(response.bodyBytes);
    return Run.listFromJson(jsonDecode(body));
  }

  Future<List<Run>> retrieveSelfieRuns(int? userId) async {
    http.Response response =
        await http.get(Uri.parse("https://5kmrun.bg/api/selfie/user/$userId"));
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      print('hello');
      //TODO: Fix this when endpoint behaves properly

      return [];
    }

    String body = utf8.decode(response.bodyBytes);
    return Run.selfieListFromJson(jsonDecode(body));
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

    if (runs.where((r) => !r.isSelfie).length > 0) {
      this._lastOfficialRun = runs.where((r) => !r.isSelfie).first;
      this._bestOfficialRun = runs.where((r) => !r.isSelfie).reduce(
          (a, b) => (a.timeInSeconds ?? 0) < (b.timeInSeconds ?? 0) ? a : b);
      //Function.apply((r) => r.differenceFromBest = r.timeInSeconds - this._bestOfficialRun.timeInSeconds, runs.where((r) => !r.isSelfie).toList());
    }

    if (runs.where((r) => r.isSelfie).length > 0) {
      this._lastSelfieRun = runs.where((r) => r.isSelfie).first;
      this._bestSelfieRun = runs.where((r) => r.isSelfie).reduce(
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
