import 'dart:convert';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class EventsResource extends ChangeNotifier {
  String getEventUrl();

  List<Event> value;

  bool _loading = false;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  getAll() async {
    this.loading = true;

    http.Response response =
      await http.get("${this.getEventUrl()}");
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {

      print('NO EVENTS RECEIVED');
      //TODO: Fix this when endpoint behaves properly
      
      return new List<Event>();
    }

    String body = utf8.decode(response.bodyBytes);
    this.loading = false;
    this.value = Event.listFromJson(jsonDecode(body));  
    return this.value;
  }
}

class FutureEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.futureEventsUrl;
  }
}

class PastEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.pastEventsUrl;
  }
}
