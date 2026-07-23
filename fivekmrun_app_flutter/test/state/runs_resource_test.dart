import 'dart:convert';

import 'package:fivekmrun_flutter/state/fetch_exception.dart';
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

/// Routes the two endpoints [getByUserId] hits to the right payload.
MockClient _client({int selfieStatus = 200}) => MockClient((request) async {
      if (request.url.path.contains("selfie")) {
        return http.Response(jsonEncode(_selfie), selfieStatus,
            headers: _jsonHeaders);
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

    test('rethrows FetchException and stops loading when a fetch fails',
        () async {
      final resource = RunsResource(client: _client(selfieStatus: 500));

      await expectLater(
          resource.getByUserId(42), throwsA(isA<FetchException>()));
      expect(resource.loading, isFalse);
    });
  });
}
