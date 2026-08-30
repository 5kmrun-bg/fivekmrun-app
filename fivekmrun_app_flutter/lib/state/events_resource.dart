import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class EventsResource extends ChangeNotifier {
  /// Injectable for tests; defaults to a real client in production.
  final http.Client _client;

  EventsResource({http.Client? client}) : _client = client ?? http.Client();

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
      response = await _client.get(Uri.parse(getEventUrl()));
      ensureJsonResponse(response, "events");
    } catch (_) {
      loading = false;
      rethrow;
    }

    String body = utf8.decode(response.bodyBytes);
    loading = false;
    value = listFromJsonParser(jsonDecode(body));
    return value;
  }
}

class FutureEventsResource extends EventsResource {
  FutureEventsResource({super.client});

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
  PastEventsResource({super.client});

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
  XLFutureEventsResource({super.client});

  @override
  String getEventUrl() {
    return constants.xlFutureEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromXLJson(json);
  }
}

class XLPastEventsResource extends EventsResource {
  XLPastEventsResource({super.client});

  @override
  String getEventUrl() {
    return constants.xlPastEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromXLPastJson(json);
  }
}

class KidsFutureEventsResource extends EventsResource {
  KidsFutureEventsResource({super.client});

  @override
  String getEventUrl() {
    return constants.kidsFutureEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromKidsJson(json);
  }
}

class KidsPastEventsResource extends EventsResource {
  KidsPastEventsResource({super.client});

  @override
  String getEventUrl() {
    return constants.kidsPastEventsUrl;
  }

  @override
  List<Event> listFromJsonParser(json) {
    return Event.listFromKidsJson(json);
  }
}

class AllFutureEventsResource extends ChangeNotifier {
  /// Injectable for tests; forwarded to the composed per-type resources.
  final http.Client? _client;

  AllFutureEventsResource({http.Client? client}) : _client = client;

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
      var futureEvents = await FutureEventsResource(client: _client).getAll();
      var xlFutureEvents = await XLFutureEventsResource(client: _client).getAll();
      var kidsFutureEvents =
          await KidsFutureEventsResource(client: _client).getAll();

      combined = List<Event>.from(futureEvents)
        ..addAll(xlFutureEvents)
        ..addAll(kidsFutureEvents);
    } catch (_) {
      // Keep whatever was already loaded rather than blanking the events tab.
      loading = false;
      rethrow;
    }

    loading = false;
    value = combined..sortBy((e) => e.date);

    return value;
  }
}

class AllPastEventsResource extends ChangeNotifier {
  /// Injectable for tests; forwarded to the composed per-type resources.
  final http.Client? _client;

  AllPastEventsResource({http.Client? client}) : _client = client;

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
      var pastEvents = await PastEventsResource(client: _client).getAll();
      var xlPastEvents = await XLPastEventsResource(client: _client).getAll();
      var kidsPastEvents =
          await KidsPastEventsResource(client: _client).getAll();

      combined = List<Event>.from(pastEvents)
        ..addAll(xlPastEvents)
        ..addAll(kidsPastEvents);
    } catch (_) {
      // Keep whatever was already loaded rather than blanking the events tab.
      loading = false;
      rethrow;
    }

    loading = false;
    // Past events read most-recent-first (unlike future events, which are
    // soonest-first), so sort by date descending across all sources.
    value = combined..sort((a, b) => b.date.compareTo(a.date));

    return value;
  }
}
