import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

import 'package:intl/intl.dart';

class OfflineResultsResource extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  List<Result> _value;
  List<Result> get value => _value;
  set value(List<Result> v) {
    if (_value != v) {
      _value = v;
      notifyListeners();
    }
  }

  Future<List<Result>> getThisWeekResults() async {
    return _loadResultByWeek("");
  }

  Future<List<Result>> getPastWeekResults() async {
    final now = DateTime.now();
    DateTime lastWeek =
        DateTime.now().subtract(Duration(days: now.weekday - 1 + 7));

    String weekFilter = "${lastWeek.year}/${_weekNumber(lastWeek)}";

    print("WEEK FILTER: " + weekFilter);

    return _loadResultByWeek(weekFilter);
  }

  int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Future<List<Result>> _loadResultByWeek(String weekFilter) async {
    http.Response response =
        await http.get("${constants.offlineChartEndpointUrl}$weekFilter");
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      this.loading = false;

      return null;
    }

    String body = utf8.decode(response.bodyBytes);
    List<Result> results = Result.listFromJson(jsonDecode(body));
    List<Result> processedResults = processResults(results);

    this.value = processedResults;
    this.loading = false;

    return processedResults;
  }

  List<Result> processResults(List<Result> res) {
    final ofcList = res.where((r) => !r.isDisqualified);
    var ofcPos = 1;
    ofcList.forEach((r) => r.officialPosition = ofcPos++);

    var dsqPos = 1;
    final dsqList = res.where((r) => r.isDisqualified);
    dsqList.forEach((r) => r.officialPosition = dsqPos++);

    return [...ofcList, ...dsqList];
  }
}
