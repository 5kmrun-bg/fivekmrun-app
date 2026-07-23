import 'dart:convert';

import 'package:fivekmrun_flutter/state/offline_results_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

Map<String, dynamic> _selfieResult({required int type}) => {
      "u_name": "Ivan",
      "u_surname": "Petrov",
      "s_uid": 42,
      "s_time": 1500,
      "s_total_elapsed_time": 1800,
      "s_finish_pos": 1,
      "u_runs_s": 10,
      "u_sex": "M",
      "s_type": type,
      "s_start_location": "Park",
      "s_elevation_loss": 0,
      "s_elevation_gained": 0,
      "s_elevation_gained_total": 0,
      "s_map": "poly",
      "s_distance": 5000,
      "s_total_distance": 5000,
      "s_start_date": "2021-06-15T08:00:00.000",
      "s_strava_link": "http://strava",
      "p_id": null,
      "u_daritel": 0,
    };

void main() {
  group('OfflineResultsResource.getThisWeekResults', () {
    test('parses results and assigns official positions', () async {
      final body = {
        "runners": [
          _selfieResult(type: 1), // valid
          _selfieResult(type: 4), // disqualified
          _selfieResult(type: 1), // valid
        ]
      };
      final client = MockClient(
          (_) async => http.Response(jsonEncode(body), 200, headers: _jsonHeaders));
      final resource = OfflineResultsResource(client: client);

      final results = await resource.getThisWeekResults();

      expect(results, hasLength(3));
      // Non-disqualified entries are numbered first, 1..N.
      final valid = results!.where((r) => !r.isDisqualified).toList();
      expect(valid.map((r) => r.officialPosition), [1, 2]);
      // Disqualified numbering restarts at 1.
      final dsq = results.where((r) => r.isDisqualified).toList();
      expect(dsq.single.officialPosition, 1);
      expect(resource.loading, isFalse);
    });

    test('returns null on a bad response', () async {
      final client = MockClient(
          (_) async => http.Response("boom", 503, headers: _jsonHeaders));
      final resource = OfflineResultsResource(client: client);

      expect(await resource.getThisWeekResults(), isNull);
      expect(resource.loading, isFalse);
    });
  });
}
