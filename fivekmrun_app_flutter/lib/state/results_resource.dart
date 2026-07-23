import 'dart:convert';
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/state/result_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class ResultsResource extends ChangeNotifier {
  /// Injectable for tests; defaults to a real client in production.
  final http.Client _client;

  ResultsResource({http.Client? client}) : _client = client ?? http.Client();

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

    http.Response response = await _client
        .get(Uri.parse("${constants.resultEventsUrl}${eventId.toString()}"));
    if (!isJsonResponse(
        response.statusCode, response.headers["content-type"])) {
      this.loading = false;
      return [];
    }

    String body = utf8.decode(response.bodyBytes);
    this.loading = false;
    this.value = Result.listFromEventJson(jsonDecode(body)).toList();
    return this.value!;
  }
}
