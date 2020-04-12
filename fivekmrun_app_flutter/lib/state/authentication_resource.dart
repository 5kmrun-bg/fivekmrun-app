import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

class AuthenticationResource extends ChangeNotifier {
  Future<String> getToken(String username, String password) async {
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
    print(errors[0]);
    return token;
  }
}
