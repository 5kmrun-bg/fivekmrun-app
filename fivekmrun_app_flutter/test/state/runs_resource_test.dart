import 'dart:convert';

import 'package:fivekmrun_flutter/state/fetch_exception.dart';
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

/// Routes the three endpoints [getByUserId] hits to the right payload.
///
/// XL defaults to the same non-JSON "no history" response the real endpoint
/// gives most users (see [RunsResource.retrieveXLRuns]) so existing
/// official/selfie-only assertions don't need to account for an XL run
/// they didn't ask for.
MockClient _client({
  int selfieStatus = 200,
  http.Response? xlResponse,
  http.Response? officialResponse,
}) =>
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
      return officialResponse ??
          http.Response(jsonEncode(_official), 200, headers: _jsonHeaders);
    });

/// What `5kmrun/user/<id>` actually answers for a user with no official
/// results: it errors server-side and redirects to an article page, so the
/// client sees 200 text/html rather than an empty array.
final _officialNoHistoryPage = http.Response(
  "<br /> <b>Notice</b>:  Undefined offset: 0 in "
  "<b>/home/kmrunbg/appCore/classes/Logic/Pub/Petkmrun/ApiUser.php</b> "
  "on line <b>132</b><br />",
  200,
  headers: {"content-type": "text/html; charset=utf-8"},
);

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
        'rethrows FetchException and stops loading when every source fails, '
        'so a server outage never looks like "no runs"', () async {
      final resource = RunsResource(
          client: _client(
              selfieStatus: 500,
              officialResponse: http.Response("server error", 500)));

      await expectLater(
          resource.getByUserId(42), throwsA(isA<FetchException>()));
      expect(resource.loading, isFalse);
      expect(resource.value, isNull);
    });

    test(
        'keeps the selfie runs when the official endpoint serves its '
        'no-history error page', () async {
      // The reported bug: users with no official results (IDs 24342, 22237,
      // 33679) saw an empty list despite hundreds of selfie runs, because the
      // official endpoint's HTML error page aborted the whole load.
      final resource =
          RunsResource(client: _client(officialResponse: _officialNoHistoryPage));

      final runs = await resource.getByUserId(24342);

      expect(runs, hasLength(1));
      expect(runs.single.runType, RunType.selfie);
      expect(resource.lastSelfieRun, isNotNull);
      expect(resource.loading, isFalse);
    });

    test('still returns official runs when only the selfie source fails',
        () async {
      final resource = RunsResource(client: _client(selfieStatus: 500));

      final runs = await resource.getByUserId(42);

      expect(runs, hasLength(1));
      expect(runs.single.runType, RunType.official);
      expect(resource.lastOfficialRun, isNotNull);
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
  });
}
