import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;

class AuthenticationResource extends ChangeNotifier {
  String? _token;
  int? _userId;

  Future<bool> authenticate(String username, String password) async {
    FirebaseCrashlytics.instance.log("authenticate username - $username");

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/auth"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write("userEmail=$username&userPassword=$password");

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    httpClient.close();
    Map<String, dynamic> map = json.decode(reply);
    List<String> errors = List.from(map["errors"]);

    if (errors.isEmpty) {
      final token = map["answer"]["tkn"];
      final userId = map["answer"]["id"];

      if (token != null && token != "" && userId != null) {
        await this._onLoginSuccess(userId, token);

        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> authenticateWithUserId(int userId) async {
    FirebaseCrashlytics.instance.log("authenticate userID - $userId");

    await this._onLoginSuccess(userId, null);
    return true;
  }

  String? getToken() {
    return this._token;
  }

  int? getUserId() {
    return this._userId;
  }

  bool isLoggedIn() {
    return this._token != null && this._userId != null;
  }

  void _setUserId(int? userId) {
    this._userId = userId;
    FirebaseCrashlytics.instance.setUserIdentifier(userId?.toString() ?? "");
  }

  void _setToken(String? token) {
    this._token = token;
    FirebaseCrashlytics.instance
        .setCustomKey("hasToken", token != null && token != "");
  }

  Future<void> logout() async {
    FirebaseCrashlytics.instance.log("logout() started");
    this._setUserId(null);
    this._setToken(null);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(constants.key_userId);
    await prefs.remove(constants.key_token);
    await prefs.remove(constants.key_tokenTimestamp);
    FirebaseCrashlytics.instance.log("logout() completed");
  }

  Future<void> _onLoginSuccess(int userId, String? token) async {
    this._setUserId(userId);
    this._setToken(token);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(constants.key_userId, userId);

    if (token != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(constants.key_token, token);
      await prefs.setInt(constants.key_tokenTimestamp, timestamp);
    } else {
      await prefs.remove(constants.key_token);
      await prefs.remove(constants.key_tokenTimestamp);
    }
  }

  Future<void> loadFromLocalStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // load user ID
    final userId = prefs.getInt(constants.key_userId);
    this._setUserId(userId);

    final token = prefs.getString(constants.key_token);
    if (token != null) {
      final timestamp = prefs.getInt(constants.key_tokenTimestamp);
      if (timestamp != null) {
        final created = DateTime.fromMillisecondsSinceEpoch(timestamp);
        print("AUTH.loadFromLocalStore token created: ${created.toString()}");

        final expiresAt =
            created.add(new Duration(days: constants.tokenExpiryDays));
        if (expiresAt.isAfter(DateTime.now())) {
          this._setToken(token);
        }
      }
    }

    print("AUTH.loadFromLocalStore userId: ${this._userId.toString()} ");
    print("AUTH.loadFromLocalStore token: ${this._token}");
  }
}
