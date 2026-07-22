import 'package:fivekmrun_flutter/state/fetch_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isJsonResponse accepts', () {
    test('the exact content-type the API sends today', () {
      expect(isJsonResponse(200, "application/json;charset=utf-8;"), true);
    });

    // The previous exact-string check treated each of these as a failure and
    // returned an empty list, which the app rendered as "no runs yet".
    test('a content-type without the trailing semicolon', () {
      expect(isJsonResponse(200, "application/json;charset=utf-8"), true);
    });

    test('a content-type with a space before the charset', () {
      expect(isJsonResponse(200, "application/json; charset=utf-8"), true);
    });

    test('a content-type in different casing', () {
      expect(isJsonResponse(200, "Application/JSON;charset=UTF-8"), true);
    });

    test('a bare application/json', () {
      expect(isJsonResponse(200, "application/json"), true);
    });

    test('a content-type with leading whitespace', () {
      expect(isJsonResponse(200, "  application/json"), true);
    });
  });

  group('isJsonResponse rejects', () {
    test('a 500 status', () {
      expect(isJsonResponse(500, "application/json;charset=utf-8;"), false);
    });

    test('a 404 status', () {
      expect(isJsonResponse(404, "application/json;charset=utf-8;"), false);
    });

    test('an HTML error page served with a 200', () {
      expect(isJsonResponse(200, "text/html"), false);
    });

    test('a missing content-type', () {
      expect(isJsonResponse(200, null), false);
    });

    test('a content-type that only mentions json later', () {
      expect(
          isJsonResponse(200, "text/html; fallback=application/json"), false);
    });
  });

  test('FetchException message names the resource and the cause', () {
    const exception = FetchException("5km runs", 503, "text/html");

    expect(exception.toString(), contains("5km runs"));
    expect(exception.toString(), contains("503"));
    expect(exception.toString(), contains("text/html"));
  });

  test('FetchException message copes with a missing content-type', () {
    const exception = FetchException("events", 500, null);

    expect(exception.toString(), contains("none"));
  });
}
