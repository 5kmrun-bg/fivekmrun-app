import 'dart:convert';

import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

// One object carrying every key the three parsers read, so the same payload
// works regardless of which event endpoint is requested.
List<Map<String, dynamic>> _events() => [
      {
        "e_id": 1,
        "e_title": "Race",
        "e_date": 1609459200,
        "e_time": "09:00",
        "n_name": "Sofia",
        "e_sponsor": "logo.png",
      }
    ];

void main() {
  group('FutureEventsResource.getAll', () {
    test('parses events and clears loading on success', () async {
      final client = MockClient((_) async =>
          http.Response(jsonEncode(_events()), 200, headers: _jsonHeaders));
      final resource = FutureEventsResource(client: client);

      final events = await resource.getAll();

      expect(events, hasLength(1));
      expect(events.first.title, "Race");
      expect(resource.loading, isFalse);
    });

    test('keeps previous value and rethrows on a failed fetch', () async {
      final client = MockClient(
          (_) async => http.Response("nope", 500, headers: _jsonHeaders));
      final resource = FutureEventsResource(client: client);

      await expectLater(resource.getAll(), throwsA(isA<FetchException>()));
      expect(resource.value, isEmpty); // untouched
      expect(resource.loading, isFalse);
    });
  });

  group('AllFutureEventsResource.getAll', () {
    test('combines the three future-event sources', () async {
      final client = MockClient((_) async =>
          http.Response(jsonEncode(_events()), 200, headers: _jsonHeaders));
      final resource = AllFutureEventsResource(client: client);

      final events = await resource.getAll();

      // One event from each of Future, XL and Kids sources.
      expect(events, hasLength(3));
      expect(resource.loading, isFalse);
    });

    test('rethrows if any composed source fails', () async {
      final client = MockClient(
          (_) async => http.Response("nope", 500, headers: _jsonHeaders));
      final resource = AllFutureEventsResource(client: client);

      await expectLater(resource.getAll(), throwsA(isA<FetchException>()));
    });
  });
}
