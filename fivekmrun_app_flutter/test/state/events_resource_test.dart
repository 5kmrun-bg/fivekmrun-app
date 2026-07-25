import 'dart:convert';

import 'package:fivekmrun_flutter/state/event_model.dart';
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

  group('XLPastEventsResource.getAll', () {
    test('parses each row as its own ungrouped XLEvent', () async {
      final client = MockClient((_) async => http.Response(
          jsonEncode([
            {
              "e_id": 393,
              "n_name": "Сеславци 15.2 км",
              "e_date": 1783803600,
              "e_time": "10:00",
            },
            {
              "e_id": 394,
              "n_name": "Сеславци 7.6 км",
              "e_date": 1783803600,
              "e_time": "10:00",
            },
          ]),
          200,
          headers: _jsonHeaders));
      final resource = XLPastEventsResource(client: client);

      final events = await resource.getAll();

      // Same day/location, but NOT grouped — each distance tier is its own
      // separate leaderboard, unlike the future-events grouping.
      expect(events, hasLength(2));
      expect(events.every((e) => e is XLEvent), isTrue);
    });
  });

  group('AllPastEventsResource.getAll', () {
    test('combines regular and XL past-event sources', () async {
      final client = MockClient((_) async =>
          http.Response(jsonEncode(_events()), 200, headers: _jsonHeaders));
      final resource = AllPastEventsResource(client: client);

      final events = await resource.getAll();

      // One from PastEventsResource, one from XLPastEventsResource.
      expect(events, hasLength(2));
      expect(resource.loading, isFalse);
    });

    test('rethrows if any composed source fails', () async {
      final client = MockClient(
          (_) async => http.Response("nope", 500, headers: _jsonHeaders));
      final resource = AllPastEventsResource(client: client);

      await expectLater(resource.getAll(), throwsA(isA<FetchException>()));
    });

    test('sorts the merged past events by date, most recent first', () async {
      // The regular past event is OLDER (2020); the XL past event is NEWER
      // (2023). Regardless of which source is appended first, the merged list
      // must lead with the most recent event.
      final client = MockClient((request) async {
        final bool isXl = request.url.path.contains("xlrun");
        return http.Response(
            jsonEncode([
              {
                "e_id": isXl ? 394 : 1,
                "e_title": isXl ? "" : "Old Race",
                "e_date": isXl ? 1700000000 : 1600000000,
                "e_time": "09:00",
                "n_name": isXl ? "Сеславци 7.6 км" : "Sofia",
                "e_sponsor": "",
              }
            ]),
            200,
            headers: _jsonHeaders);
      });
      final resource = AllPastEventsResource(client: client);

      final events = await resource.getAll();

      expect(events, hasLength(2));
      expect(events.first.date.isAfter(events.last.date), isTrue,
          reason: "past events should be ordered most-recent-first");
      expect(events.first.date.millisecondsSinceEpoch, 1700000000 * 1000);
    });
  });
}
