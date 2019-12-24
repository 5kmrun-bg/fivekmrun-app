import 'package:fivekmrun_flutter/state/resource.dart';
import 'package:fivekmrun_flutter/state/user_model.dart';

import '../constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String userIdKey = "5kmrun_UserID";

class UserResource extends Resource<User> {
  @override
  Future<http.Response> fetch(int id) {
    // return Future.delayed(Duration(seconds: 2), () => http.get("${constants.userUrl}$id"));
    return http.get("${constants.userUrl}$id");
  }

  @override
  User parse(Document doc) {
    return User(
        id: currentlyLoadingId,
        avatarUrl: parseAvatarUrl(doc),
        name: parseName(doc),
        suuntoPoints: parseUserPoints(doc),
        runsCount: parseRunsCount(doc),
        totalKmRan: parseTotalKmRan(doc),
        age: parseAge(doc));
  }

  @override
  void valueUpdated(User val) async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(userIdKey, val?.id ?? 0);
  }

  Future<int> presistedId() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  static String parseAvatarUrl(Document doc) {
    var el = doc.querySelector("div.row div figure img");
    String url = el.attributes["src"];
    if (url != null) {
      url = url.replaceFirst("http://5kmrun.bg/", "http://old.5kmrun.bg/");
    }
    return url;
  }

  static String parseName(Document doc) {
    String title = doc.querySelectorAll("h2.article-title").first.innerHtml;

    if (title.indexOf("-") > 0) {
      title = title.substring(title.indexOf("-") + 2);
    }

    return title;
  }

  static int parseRunsCount(Document doc) {
    return int.parse(
        doc.querySelectorAll("div.col-md-12 h2.article-title>span").first.text);
  }

  static double parseTotalKmRan(Document doc) {
    return double.parse(
        doc.querySelectorAll("div.col-md-12 h2.article-title>span").last.text);
  }

  static int parseAge(Document doc) {
    var str = doc
        .querySelectorAll("div.container .col-md-9 table tbody td")
        .first
        .text
        .replaceAll("г.", "");

    return int.parse(str);
  }

  static int parseUserPoints(Document doc) {
    return int.parse(doc
        .querySelectorAll("div.container .col-md-9 table tbody td")
        .last
        .text);
  }
}
