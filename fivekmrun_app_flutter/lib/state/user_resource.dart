import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/state/run_simple_model.dart';
import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

import 'package:intl/intl.dart';

class UserResource extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  User? _value;
  User? get value => _value;
  set value(User? v) {
    if (_value != v) {
      _value = v;
      notifyListeners();
    }
  }

  int? _currentUserId;
  int? get currentUserId => _currentUserId;
  set currentUserId(int? v) {
    this._currentUserId = v;
    if (v != null) {
      this.getById(v, true);
    } else {
      this.value = null;
    }
  }

  clear() {
    this.currentUserId = null;
    this.value = null;
    this.loading = false;
  }

  Future<User?> getById(int userId, [bool force = false]) async {
    if (userId == 0) {
      return null;
    }

    if (!force && userId != 0 && userId == currentUserId) {
      return value;
    }

    this.loading = true;

    http.Response response = await http
        .get(Uri.dataFromString("${constants.userEndpointUrl}$userId"));
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      this.loading = false;
      //TODO: Fix this when endpoint behaves properly
      this.value =
          new User(age: 0, name: " ", donationsCount: 0, id: -1, avatarUrl: "");
      return this.value;
    }

    String body = utf8.decode(response.bodyBytes);
    dynamic decodedBody = jsonDecode(body);
    User user = User.fromJson(userId, decodedBody);
    List<RunSimple> runs = RunSimple.listFromJson(decodedBody);

    this._sendToAnalytics(user, runs);
    this.value = user;
    this.loading = false;
    return user;
  }

  void _sendToAnalytics(User user, List<RunSimple> runs) {
    FirebaseAnalytics().setUserProperty(
        name: "age", value: user.age.toString().padLeft(2, '0'));
    FirebaseAnalytics().setUserProperty(
        name: "donation_total",
        value: user.donationsCount.toString().padLeft(3, '0'));
    if (runs.length > 0) {
      runs.sort((r1, r2) => r1.date.compareTo(r2.date));

      RunSimple lastRun = runs.last;

      FirebaseAnalytics().setUserProperty(
          name: "selfie_last_run",
          value: DateFormat("yyyy-MM-dd").format(lastRun.date));
      FirebaseAnalytics().setUserProperty(
          name: "selfie_total_runs", value: runs.length.toString());
    }
  }
}
