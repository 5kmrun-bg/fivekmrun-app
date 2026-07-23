import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _jsonHeaders = {"content-type": "application/json; charset=utf-8"};

void main() {
  // NOTE: the success path calls FirebaseAnalytics and so needs an initialised
  // Firebase; these tests cover the id-guard and offline/bad-response fallbacks,
  // which are the paths that used to be untestable.
  group('UserResource.getById', () {
    test('returns null for user id 0 without hitting the network', () async {
      var called = false;
      final resource = UserResource(client: MockClient((_) async {
        called = true;
        return http.Response("{}", 200, headers: _jsonHeaders);
      }));

      expect(await resource.getById(0), isNull);
      expect(called, isFalse);
    });

    test('falls back to a barcode-only user when the network throws', () async {
      final resource = UserResource(client: MockClient(
          (_) async => throw http.ClientException("offline")));

      final user = await resource.getById(42);

      expect(user, isNotNull);
      expect(user!.id, 42); // keeps the requested id for the barcode
      expect(resource.loading, isFalse);
    });

    test('falls back to an empty user on a non-JSON response', () async {
      final resource = UserResource(client: MockClient((_) async =>
          http.Response("<html/>", 200, headers: {"content-type": "text/html"})));

      final user = await resource.getById(42);

      expect(user, isNotNull);
      expect(user!.id, -1); // sentinel for "server misbehaved"
      expect(resource.loading, isFalse);
    });
  });
}
