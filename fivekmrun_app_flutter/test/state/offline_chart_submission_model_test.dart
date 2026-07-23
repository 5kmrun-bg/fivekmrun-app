import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  OfflineChartSubmissionModel makeModel() => OfflineChartSubmissionModel(
        userId: "42",
        elapsedTime: 1500,
        distance: 5000.0,
        startDate: DateTime(2021, 6, 15, 8, 0, 0),
        mapPath: "polyline",
        startGeoLocation: [42.1, 23.2],
        elevationLow: 1.0,
        elevationHigh: 2.0,
        elevationGainedTotal: 3.0,
        startLocation: "Park",
        totalDistance: 6000.0,
        totalElapsedTime: 1800,
        stravaLink: "http://strava/1",
        segments: [10, 20, null],
      );

  group('OfflineChartSubmissionModel.toJson', () {
    test('serializes the primitive fields', () {
      final json = makeModel().toJson();
      expect(json["userId"], "42");
      expect(json["elapsedTime"], 1500);
      expect(json["distance"], 5000.0);
      expect(json["startDate"], DateTime(2021, 6, 15, 8, 0, 0).toString());
      expect(json["mapPath"], "polyline");
      expect(json["startGeoLocation"], [42.1, 23.2]);
      expect(json["elevationLow"], 1.0);
      expect(json["elevationHigh"], 2.0);
      expect(json["elevationGainedTotal"], 3.0);
      expect(json["startLocation"], "Park");
      expect(json["stravaLink"], "http://strava/1");
    });

    test('stringifies the segments list', () {
      final json = makeModel().toJson();
      expect(json["segments"], "[10, 20, null]");
    });
  });
}
