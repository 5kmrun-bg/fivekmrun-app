import 'dart:convert';

import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

final _official = {
  "runners": [
    {
      "r_id": 1,
      "r_eventid": 1,
      "e_date": 1609459200,
      "r_time": 1500,
      "n_name": "Sofia",
      "r_finish_pos": 1,
    }
  ]
};

final _selfie = {
  "runs": [
    {
      "s_id": 2,
      "s_start_date": "2021-06-15T08:00:00.000",
      "s_time": 1800,
      "s_finish_pos": 1,
    }
  ]
};

final _xl = {
  "runners": [
    {
      "r_id": 3,
      "r_eventid": 300,
      "e_date": 1609459200,
      "r_time": 3766,
      "n_name": "Сеславци 7.6 км",
      "r_finish_pos": 1,
    }
  ]
};

final _kids = {
  "runners": [
    {
      "r_id": 4,
      "r_eventid": 519,
      "e_date": 1784322000,
      "r_time": 700,
      "n_name": "Южен Парк Kids",
      "r_finish_pos": 1,
    }
  ]
};

/// Routes the four endpoints [getByUserId] hits to the right payload.
///
/// XL and Kids default to the same non-JSON "no history" response the real
/// endpoints give most users (see [RunsResource.retrieveXLRuns]/
/// [RunsResource.retrieveKidsRuns]) so existing official/selfie-only
/// assertions don't need to account for runs they didn't ask for.
MockClient _client(
        {int selfieStatus = 200,
        http.Response? xlResponse,
        http.Response? kidsResponse}) =>
    MockClient((request) async {
      if (request.url.path.contains("selfie")) {
        return http.Response(jsonEncode(_selfie), selfieStatus,
            headers: _jsonHeaders);
      }
      if (request.url.path.contains("xlrun")) {
        return xlResponse ??
            http.Response("<html>not found</html>", 200,
                headers: {"content-type": "text/html; charset=utf-8"});
      }
      if (request.url.path.contains("kidsrun")) {
        return kidsResponse ??
            http.Response("<html>not found</html>", 200,
                headers: {"content-type": "text/html; charset=utf-8"});
      }
      return http.Response(jsonEncode(_official), 200, headers: _jsonHeaders);
    });

void main() {
  group('RunsResource.getByUserId', () {
    test('merges official and selfie runs on success', () async {
      final resource = RunsResource(client: _client());

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(2));
      expect(resource.loading, isFalse);
      expect(resource.lastOfficialRun, isNotNull);
      expect(resource.lastSelfieRun, isNotNull);
      expect(resource.bestOfficialRun!.timeInSeconds, 1500);
    });

    test('returns cached value without fetching when userId is null', () async {
      var called = false;
      final resource = RunsResource(client: MockClient((_) async {
        called = true;
        return http.Response("{}", 200, headers: _jsonHeaders);
      }));

      final runs = await resource.getByUserId(null);

      expect(runs, isEmpty);
      expect(called, isFalse);
    });

    test(
        'tolerates a single failing source: keeps the runs that did load '
        'instead of blanking the whole list', () async {
      // selfie 500s, but 5km succeeds — the user should still see their
      // 5km runs rather than an empty/error list.
      final resource = RunsResource(client: _client(selfieStatus: 500));

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(1));
      expect(runs.single.runType, RunType.official);
      expect(resource.loading, isFalse);
    });

    test(
        'surfaces Kids runs even when the 5km and selfie endpoints answer '
        'with non-JSON — a Kids-only participant has no 5km/selfie history, '
        'and that must not blank their Kids runs', () async {
      final client = MockClient((request) async {
        if (request.url.path.contains("kidsrun")) {
          return http.Response(jsonEncode(_kids), 200, headers: _jsonHeaders);
        }
        // 5km, selfie and xl all answer with a non-JSON "no history" page.
        return http.Response("<html>no history</html>", 200,
            headers: {"content-type": "text/html; charset=utf-8"});
      });
      final resource = RunsResource(client: client);

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(1));
      expect(runs.single.runType, RunType.kids);
      expect(resource.loading, isFalse);
    });

    test(
        'rethrows and keeps the cached runs when every source fails '
        '(a real outage must not wipe history)', () async {
      final cached = [Run.fromKidsJson(_kids["runners"]![0])];
      final resource = RunsResource(
          client: MockClient((_) async => throw http.ClientException("down")))
        ..value = cached;

      await expectLater(
          resource.getByUserId(42), throwsA(isA<Exception>()));
      expect(resource.value, same(cached));
      expect(resource.loading, isFalse);
    });

    test('merges XL runs in when the endpoint answers with JSON', () async {
      final resource = RunsResource(
          client: _client(
              xlResponse: http.Response(jsonEncode(_xl), 200,
                  headers: _jsonHeaders)));

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(3));
      expect(runs.where((r) => r.runType == RunType.xl), hasLength(1));
    });

    test(
        'treats a non-JSON XL response as "no XL runs" rather than a fetch '
        'failure — this is what the real endpoint answers for the vast '
        'majority of users who have no XL history', () async {
      final resource = RunsResource(client: _client());

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(2));
      expect(resource.loading, isFalse);
    });

    test('merges Kids runs in when the endpoint answers with JSON', () async {
      final resource = RunsResource(
          client: _client(
              kidsResponse: http.Response(jsonEncode(_kids), 200,
                  headers: _jsonHeaders)));

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(3));
      expect(runs.where((r) => r.runType == RunType.kids), hasLength(1));
    });

    test(
        'treats a non-JSON Kids response as "no Kids runs" rather than a '
        'fetch failure — this is what the real endpoint answers for the '
        'vast majority of users who have no Kids history', () async {
      final resource = RunsResource(client: _client());

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(2));
      expect(resource.loading, isFalse);
    });
  });
}
