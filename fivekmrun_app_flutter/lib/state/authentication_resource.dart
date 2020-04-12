import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

class AuthenticationResource extends ChangeNotifier {

  String _token;
  String _username;
  String _password;

  Future<bool> authenticate(String username, String password) async {
    this._username = username;
    this._password = password;

    return this.refreshToken();
  }

  Future<bool> refreshToken() async {
    this._token = await this._getToken(this._username, this._password);

    if (this._token != null && this._token != "") {
      return true;
    } else {
      return false;
    }
  }

  String getToken() {
    return this._token;
  }

  Future<void> logout() {
    this._username = null;
    this._password = null;
    this._token = null;

    return null;
  }

  Future<String> _getToken(String username, String password) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/auth"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write("userEmail=${username}&userPassword=${password}");

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    httpClient.close();
    Map<String, dynamic> map = json.decode(reply);

    String token  = map["answer"];
    List<String> errors = List.from(map["errors"]);

    return token;
  }
}
