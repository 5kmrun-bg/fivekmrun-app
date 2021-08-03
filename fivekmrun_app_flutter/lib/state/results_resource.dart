import 'dart:convert';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ResultsResource extends ChangeNotifier {
  List<Result>? value;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  Future<List<Result>> getAll(int eventId) async {
    this.loading = true;

    http.Response response = await http.get(Uri.dataFromString(
        "${constants.resultEventsUrl}${eventId.toString()}"));
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      print('NO RESULTS RECEIVED');
      //TODO: Fix this when endpoint behaves properly

      return [];
    }

    String body = utf8.decode(response.bodyBytes);
    this.loading = false;
    this.value = Result.listFromEventJson(jsonDecode(body)).toList();
    return this.value!;
  }
}
