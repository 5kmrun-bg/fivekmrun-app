import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/state/run_simple_model.dart';
import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

import 'package:intl/intl.dart';

class UserResource extends ChangeNotifier {
  /// Injectable for tests; defaults to a real client in production.
  final http.Client _client;

  UserResource({http.Client? client}) : _client = client ?? http.Client();

  bool _loading = true;

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
      // Show barcode immediately; getById will overwrite with full profile data.
      this.value = User(age: 0, name: "", donationsCount: 0, id: v, avatarUrl: "");
      this._loading = false;
      this.getById(v, true);
    } else {
      this.value = null;
    }
  }

  clear() {
    this.currentUserId = null;
    this.value = null;
    this.loading = true;
  }

  Future<User?> getById(int userId, [bool force = false]) async {
    if (userId == 0) {
      return null;
    }

    if (!force && userId != 0 && userId == currentUserId) {
      return value;
    }

    http.Response? response;
    try {
      response =
          await _client.get(Uri.parse("${constants.userEndpointUrl}$userId"));
    } catch (e) {
      // No internet or server unreachable — show barcode with cached user ID.
      this.loading = false;
      this.value = new User(age: 0, name: "", donationsCount: 0, id: userId, avatarUrl: "");
      return this.value;
    }

    if (!isJsonResponse(
        response.statusCode, response.headers["content-type"])) {
      this.loading = false;
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
    FirebaseAnalytics.instance.setUserProperty(
        name: "age", value: user.age.toString().padLeft(2, '0'));
    FirebaseAnalytics.instance.setUserProperty(
        name: "donation_total",
        value: user.donationsCount.toString().padLeft(3, '0'));
    if (runs.length > 0) {
      runs.sort((r1, r2) => r1.date.compareTo(r2.date));

      RunSimple lastRun = runs.last;

      FirebaseAnalytics.instance.setUserProperty(
          name: "selfie_last_run",
          value: DateFormat("yyyy-MM-dd").format(lastRun.date));
      FirebaseAnalytics.instance.setUserProperty(
          name: "selfie_total_runs", value: runs.length.toString());
    }
  }
}
