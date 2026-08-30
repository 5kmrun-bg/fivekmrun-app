import 'dart:convert';
import 'dart:io';

import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:flutter/widgets.dart';

/// Builds the `application/x-www-form-urlencoded` body for the `/api/selfie`
/// submission endpoint. Only `start_location` goes through
/// [Uri.encodeQueryComponent] — the other fields are numeric, ISO-ish
/// timestamps, or already-safe identifiers, so they're written as-is.
String buildOfflineChartSubmissionBody(
    OfflineChartSubmissionModel model, String authToken) {
  String body = "";

  body += "user_id=${model.userId}";
  body += "&elapsed_time=${model.elapsedTime}";
  body += "&s_total_elapsed_time=${model.totalElapsedTime}";
  body += "&distance=${model.distance}";
  body += "&s_total_distance=${model.totalDistance}";
  body += "&start_date=${model.startDate}";
  body += "&tkn=$authToken";
  body += "&map=${model.mapPath}";
  body += "&start_location=${Uri.encodeQueryComponent(model.startLocation)}";
  body += "&elevation_loss=${model.elevationLow}";
  body += "&elevation_gained=${model.elevationHigh}";
  body += "&elevation_gained_total=${model.elevationGainedTotal}";
  body += "&s_strava_link=${model.stravaLink}";
  body += "&segments=${model.segments}";
  body += "&gps=${model.startGeoLocation[0]},${model.startGeoLocation[1]}";

  return body;
}

class OfflineChartResource extends ChangeNotifier {
  Future<Map<String, dynamic>> submitEntry(
      OfflineChartSubmissionModel model, String authToken) async {
    final body = buildOfflineChartSubmissionBody(model, authToken);

    HttpClient httpClient = HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/selfie"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write(body);

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return json.decode(reply);
  }
}
