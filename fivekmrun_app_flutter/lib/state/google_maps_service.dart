import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/private/secrets.dart';

class GoogleMapsService {
  Future<String> getTownFromGeoLocation(double latitude, double longitude) async {
    http.Response response = 
      await http.get("https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&sensor=true&key=$googleMapsKey");

    if (response.statusCode != 200) {
      Crashlytics.instance.recordError(Exception("Error accessing Google Maps API"), StackTrace.current);
      return "";
    }

    String body = utf8.decode(response.bodyBytes);
    final decodedResponse = jsonDecode(body);
    String status = decodedResponse["status"];

    if (status != "OK") {
      Crashlytics.instance.recordError(Exception("Error accessing Google Maps API: " + decodedResponse["error_message"]), StackTrace.current);
      return "";      
    }

    List<dynamic> result = decodedResponse["results"];

    if (result.length > 0 ) {
      final addressComponent = result.where((ac) => ac["types"].contains("locality"))?.first;
      return addressComponent["address_components"]?.first["short_name"] ?? "";
    }

    return "";  
  }
}