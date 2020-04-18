import 'package:fivekmrun_flutter/state/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
    _currentUserId = v;
    this.getById(v, true);
  }

  Future<User> getById(int userId, [bool force = false]) async {
    if (!force && userId != 0 && userId == currentUserId) {
      return value;
    }

    this.loading = true;

    http.Response response = await http.get("${constants.userEndpointUrl}$userId");
    if (response.statusCode != 200 || response.headers["content-type"] != "application/json;charset=utf-8;") {
      this.loading = false;
      //TODO: Fix this when endpoint behaves properly
      this.value = new User(age: 23, name: "fake user", runsCount: 23,);
      return this.value;
    }
    
    String body = utf8.decode(response.bodyBytes);
    User user = User.fromJson(jsonDecode(body));
    this.value = user;
    this.loading = false;
    return user;
  }

  Future<int> presistedId() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(constants.userIdKey);
  }
}
