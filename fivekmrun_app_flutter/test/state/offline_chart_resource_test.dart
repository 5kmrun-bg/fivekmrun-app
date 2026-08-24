import 'package:fivekmrun_flutter/state/offline_chart_resource.dart';
import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _unset = Object();

OfflineChartSubmissionModel _model({
  String userId = '13731',
  int elapsedTime = 1500,
  double distance = 5.0,
  DateTime? startDate,
  String mapPath = '/maps/abc123.png',
  List<double> startGeoLocation = const [42.6977, 23.3219],
  double elevationLow = 10.5,
  double elevationHigh = 55.25,
  double elevationGainedTotal = 44.75,
  String startLocation = 'Borisova gradina',
  double totalDistance = 5.2,
  int totalElapsedTime = 1560,
  String stravaLink = 'https://strava.com/activities/1',
  Object? segments = _unset,
}) {
  final resolvedSegments =
      identical(segments, _unset) ? const [1, 2, null] : segments as List<int?>?;
  return OfflineChartSubmissionModel(
    userId: userId,
    elapsedTime: elapsedTime,
    distance: distance,
    startDate: startDate ?? DateTime(2026, 8, 25, 9, 30),
    mapPath: mapPath,
    startGeoLocation: startGeoLocation,
    elevationLow: elevationLow,
    elevationHigh: elevationHigh,
    elevationGainedTotal: elevationGainedTotal,
    startLocation: startLocation,
    totalDistance: totalDistance,
    totalElapsedTime: totalElapsedTime,
    stravaLink: stravaLink,
    segments: resolvedSegments,
  );
}

void main() {
  group('buildOfflineChartSubmissionBody', () {
    test('encodes every field into the expected key=value pairs', () {
      final body = buildOfflineChartSubmissionBody(_model(), 'auth-token-1');

      final pairs = body.split('&');
      expect(pairs, containsAll(<String>[
        'user_id=13731',
        'elapsed_time=1500',
        's_total_elapsed_time=1560',
        'distance=5.0',
        's_total_distance=5.2',
        'start_date=2026-08-25 09:30:00.000',
        'tkn=auth-token-1',
        'map=/maps/abc123.png',
        'start_location=Borisova+gradina',
        'elevation_loss=10.5',
        'elevation_gained=55.25',
        'elevation_gained_total=44.75',
        's_strava_link=https://strava.com/activities/1',
        'segments=[1, 2, null]',
        'gps=42.6977,23.3219',
      ]));
    });

    test('URL-encodes start_location but leaves other free-text fields raw',
        () {
      final body = buildOfflineChartSubmissionBody(
          _model(startLocation: 'кв. Лозенец, ул. "Кричим" 5&6'), 'tok');

      expect(body, contains('start_location=%D0%BA%D0%B2.'));
      expect(body, isNot(contains('start_location=кв.')));
      // Unencoded fields keep their raw text verbatim.
      expect(body, contains('map=/maps/abc123.png'));
    });

    test('joins the two-element gps pair with a comma, no encoding', () {
      final body = buildOfflineChartSubmissionBody(
          _model(startGeoLocation: [-1.5, 100.25]), 'tok');

      expect(body, contains('gps=-1.5,100.25'));
    });

    test('renders a null segments list as the literal string "null"', () {
      final body =
          buildOfflineChartSubmissionBody(_model(segments: null), 'tok');

      expect(body, contains('segments=null'));
    });

    test('fields appear in a stable, documented order', () {
      final body = buildOfflineChartSubmissionBody(_model(), 'tok');

      final keys = body.split('&').map((pair) => pair.split('=').first);
      expect(
          keys,
          [
            'user_id',
            'elapsed_time',
            's_total_elapsed_time',
            'distance',
            's_total_distance',
            'start_date',
            'tkn',
            'map',
            'start_location',
            'elevation_loss',
            'elevation_gained',
            'elevation_gained_total',
            's_strava_link',
            'segments',
            'gps',
          ]);
    });
  });
}
