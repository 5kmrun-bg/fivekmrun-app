import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class EventsResource extends ChangeNotifier {
  String getEventUrl();

  // Not `late`: a failed fetch now leaves [value] untouched, so it has to be
  // readable before the first successful load.
  List<Event> value = <Event>[];

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
    final http.Response response;
    try {
      response = await http.get(Uri.parse("${this.getEventUrl()}"));
      ensureJsonResponse(response, "events");
    } catch (_) {
      this.loading = false;
      rethrow;
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
  // Not `late`: a failed fetch now leaves [value] untouched, so it has to be
  // readable before the first successful load.
  List<Event> value = <Event>[];

  bool _loading = true;

  bool get loading => _loading;
  set loading(bool value) {
    if (_loading != value) {
      _loading = value;
      notifyListeners();
    }
  }

  Future<List<Event>> getAll() async {
    final List<Event> combined;
    try {
      var futureEvents = await FutureEventsResource().getAll();
      var xlFutureEvents = await XLFutureEventsResource().getAll();
      var kidsFutureEvents = await KidsFutureEventsResource().getAll();

      combined = List<Event>.from(futureEvents)
        ..addAll(xlFutureEvents)
        ..addAll(kidsFutureEvents);
    } catch (_) {
      // Keep whatever was already loaded rather than blanking the events tab.
      this.loading = false;
      rethrow;
    }

    this.loading = false;
    this.value = combined..sortBy((e) => e.date);

    return this.value;
  }
}
