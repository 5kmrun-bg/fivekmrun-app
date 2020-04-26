import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

class UserResource extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  User _value;
  User get value => _value;
  set value(User v) {
    if (_value != v) {
      _value = v;
      notifyListeners();
    }
  }

  int _currentUserId;
  int get currentUserId => _currentUserId;
  set currentUserId(int v) {
    this._currentUserId = v;
    Crashlytics.instance.setUserIdentifier(v.toString());
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

  Future<User> getById(int userId, [bool force = false]) async {
    if (userId == 0) {
      return null;
    }

    if (!force && userId != 0 && userId == currentUserId) {
      return value;
    }

    this.loading = true;

    http.Response response =
        await http.get("${constants.userEndpointUrl}$userId");
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      this.loading = false;
      //TODO: Fix this when endpoint behaves properly
      this.value = new User(
        age: 0,
        name: " ",
      );
      return this.value;
    }

    String body = utf8.decode(response.bodyBytes);
    User user = User.fromJson(userId, jsonDecode(body));
    this.value = user;
    this.loading = false;
    return user;
  }
}
