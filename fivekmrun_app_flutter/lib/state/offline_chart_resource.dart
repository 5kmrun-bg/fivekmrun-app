import 'dart:convert';
import 'dart:io';

import 'package:fivekmrun_flutter/state/offline_chart_submission_model.dart';
import 'package:flutter/widgets.dart';

class OfflineChartResource extends ChangeNotifier {
  Future<Map<String, dynamic>> submitEntry(
      OfflineChartSubmissionModel model, String authToken) async {
    String body = "";

    body += "user_id=" + model.userId;
    body += "&elapsed_time=" + model.elapsedTime.toString();
    body += "&distance=" + model.distance.toString();
    body += "&start_date=" + model.startDate.toString();
    body += "&tkn=" + authToken;
    body += "&map=" + model.mapPath;
    body += "&start_location" + model.startLocation;
    body += "&elevation_loss=" + model.elevationLow.toString();
    body += "&elevation_gained=" + model.elevationHigh.toString();
    body += "&elevation_gained_total=" + model.elevationGainedTotal.toString();
    body += "&gps=" +
        model.startGeoLocation[0].toString() +
        "," +
        model.startGeoLocation[1].toString();

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse("https://5kmrun.bg/api/selfie"));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.write(body);

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    httpClient.close();
    return json.decode(reply);
  }
}
