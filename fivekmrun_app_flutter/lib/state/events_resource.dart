import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class EventsResource extends ChangeNotifier {
  String getEventUrl();

  late List<Event> value;

  bool _loading = true;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  List<Event> listFromJsonParser(dynamic json);

  Future<List<Event>> getAll() async {
    http.Response response = await http.get(Uri.parse("${this.getEventUrl()}"));
    if (response.statusCode != 200 ||
        response.headers["content-type"] != "application/json;charset=utf-8;") {
      print('NO EVENTS RECEIVED');
      //TODO: Fix this when endpoint behaves properly

      return [];
    }

    String body = utf8.decode(response.bodyBytes);
    this.loading = false;
    this.value = listFromJsonParser(jsonDecode(body));
    return this.value;
  }
}

class FutureEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.futureEventsUrl;
  }
  
  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromJson(json);
  }
}

class PastEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.pastEventsUrl;
  }
  
  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromJson(json);
  }
}

class XLFutureEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.xlFutureEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromXLJson(json);
  }
}

class KidsFutureEventsResource extends EventsResource {
  @override
  String getEventUrl() {
    return constants.kidsFutureEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromKidsJson(json);
  }
}

class AllFutureEventsResource extends ChangeNotifier {
  late List<Event> value;

  bool _loading = true;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  Future<List<Event>> getAll() async {
    var futureEvents = await FutureEventsResource().getAll();
    var xlFutureEvents = await XLFutureEventsResource().getAll();
    var kidsFutureEvents = await KidsFutureEventsResource().getAll();

    this.loading = false;
    this.value = List<Event>.from(futureEvents)..addAll(xlFutureEvents)..addAll(kidsFutureEvents);
    this.value.sortBy((e) => e.date);
    
    return this.value;
  }
}