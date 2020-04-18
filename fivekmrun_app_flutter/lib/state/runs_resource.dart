import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

class RunsResource extends ChangeNotifier {
  Run _bestRun;
  Run _lastRun;
  
  Run get bestRun {
    if (_bestRun == null) {
      _bestRun =
          value?.reduce((a, b) => a.timeInSeconds < b.timeInSeconds ? a : b);
    }
    return _bestRun;
  }

  Run get lastRun {
    if (_lastRun == null) {
      _lastRun = value?.first;
    }
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

  Future<List<Run>> getByUserId(int userId) async {
    this.loading = true;

    http.Response response =
        await http.get("${constants.userEndpointUrl}$userId");
    if (response.statusCode != 200) {
      this.loading = false;
      return null;
    }

    String body = utf8.decode(response.bodyBytes);
    List<Run> runs = Run.listFromJson(jsonDecode(body));
    this.value = runs;
    this.loading = false;
    return runs;
  }
}
