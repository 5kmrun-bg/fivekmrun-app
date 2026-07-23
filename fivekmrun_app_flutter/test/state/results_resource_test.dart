import 'dart:convert';

import 'package:fivekmrun_flutter/state/results_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

List<Map<String, dynamic>> _officialResults() => [
      {
        "u_name": "Ana",
        "u_surname": "Ivanova",
        "r_uid": 7,
        "r_time": 1200,
        "r_finish_pos": 1,
        "r_runs": 40,
        "u_help": 15,
        "u_sex": "F",
        "p_id": null,
      }
    ];

void main() {
  group('ResultsResource.getAll', () {
    test('parses results and clears loading on success', () async {
      final client = MockClient((_) async =>
          http.Response(jsonEncode(_officialResults()), 200,
              headers: _jsonHeaders));
      final resource = ResultsResource(client: client);

      final results = await resource.getAll(99);

      expect(results, hasLength(1));
      expect(results.first.name, "Ana Ivanova");
      expect(resource.value, hasLength(1));
      expect(resource.loading, isFalse);
    });

    test('returns empty list on a non-200 response', () async {
      final client =
          MockClient((_) async => http.Response("nope", 500, headers: _jsonHeaders));
      final resource = ResultsResource(client: client);

      expect(await resource.getAll(99), isEmpty);
      expect(resource.loading, isFalse);
    });

    test('tolerates content-type casing/spacing variations (the old TODO)',
        () async {
      final client = MockClient((_) async => http.Response(
          jsonEncode(_officialResults()), 200,
          headers: {"content-type": "Application/JSON; charset=UTF-8"}));
      final resource = ResultsResource(client: client);

      final results = await resource.getAll(99);
      expect(results, hasLength(1));
    });

    test('returns empty list when the body is not JSON at all', () async {
      final client = MockClient((_) async =>
          http.Response("<html>error</html>", 200,
              headers: {"content-type": "text/html"}));
      final resource = ResultsResource(client: client);

      expect(await resource.getAll(99), isEmpty);
    });
  });
}
