import 'dart:convert';

import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The body `5kmrun/user/<id>` serves for a user with no official results: the
/// endpoint 302s to an article page, which answers 200 with HTML. Reproduced
/// from the live responses for user IDs 24342, 22237 and 33679.
const _officialErrorPageHtml = "<br /> <b>Notice</b>:  Undefined offset: 0 in "
    "<b>/home/kmrunbg/appCore/classes/Logic/Pub/Petkmrun/ApiUser.php</b> "
    "on line <b>132</b><br />";

String _selfiePayload(int count) {
  return jsonEncode({
    "user": [
      {"u_name": "Test", "u_surname": "User"}
    ],
    "runs": List.generate(
      count,
      (i) => {
        "s_id": 40815 + i,
        "s_start_date": "2022-01-"
            "${((i % 28) + 1).toString().padLeft(2, '0')} 12:02:53",
        "s_time": 2157 + i,
        "s_finish_pos": 353,
        "s_distance": 5003,
        "s_total_distance": 5003,
        "s_total_elapsed_time": 2200 + i,
      },
    ),
  });
}

const _officialPayload = '{"runners":[{'
    '"r_id":766646,"r_eventid":3285,"r_finish_pos":206,'
    '"r_time":1711,"e_date":1700000000,"n_name":"Sofia"}]}';

// The live API sends `application/json;charset=utf-8;` — the trailing
// semicolon is rejected by http.Response's own content-type parser, so it
// cannot be reproduced here. isJsonResponse matches on the prefix and is
// covered directly in fetch_exception_test.dart.
const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};
const _htmlHeaders = {"content-type": "text/html; charset=UTF-8"};

/// Routes the endpoints [RunsResource.getByUserId] hits to the given payloads.
MockClient _mockClient({
  required http.Response official,
  required http.Response selfie,
}) {
  return MockClient((request) async {
    final url = request.url.toString();
    if (url.startsWith(constants.runsEndpointUrl)) {
      return official;
    }
    if (url.startsWith("https://5kmrun.bg/api/selfie/user/")) {
      return selfie;
    }
    return http.Response("unexpected url: $url", 404);
  });
}

void main() {
  group('RunsResource.getByUserId', () {
    test(
        'keeps the selfie runs when the official endpoint serves its '
        'no-history error page', () async {
      // A user with 203 selfie runs and no official results — the official
      // endpoint answers 200 text/html after redirecting, not JSON.
      final resource = RunsResource(
        client: _mockClient(
          official: http.Response(_officialErrorPageHtml, 200,
              headers: _htmlHeaders),
          selfie: http.Response(_selfiePayload(203), 200,
              headers: _jsonHeaders),
        ),
      );

      final runs = await resource.getByUserId(24342);

      expect(runs, hasLength(203));
      expect(resource.value, hasLength(203));
      expect(resource.lastSelfieRun, isNotNull);
      expect(resource.bestSelfieRun, isNotNull);
      expect(resource.loading, isFalse);
    });

    test('still returns official runs when the selfie endpoint fails soft',
        () async {
      final resource = RunsResource(
        client: _mockClient(
          official:
              http.Response(_officialPayload, 200, headers: _jsonHeaders),
          selfie: http.Response("<html>error</html>", 200,
              headers: _htmlHeaders),
        ),
      );

      final runs = await resource.getByUserId(13731);

      expect(runs, hasLength(1));
      expect(resource.lastOfficialRun, isNotNull);
    });

    test('throws when every source fails, so old data is not wiped', () async {
      final resource = RunsResource(
        client: _mockClient(
          official: http.Response("server error", 500),
          selfie: http.Response("server error", 500),
        ),
      );

      await expectLater(
          resource.getByUserId(24342), throwsA(isA<FetchException>()));
      expect(resource.value, isNull);
      expect(resource.loading, isFalse);
    });
  });
}
