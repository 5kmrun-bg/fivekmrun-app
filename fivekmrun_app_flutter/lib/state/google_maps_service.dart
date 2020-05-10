import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:http/http.dart' as http;
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/private/secrets.dart';

class GoogleMapsService {
  Future<String> getTownFromGeoLocation(double latitude, double longitude) async {
    try {
    Geocoding geoCoder = Geocoder.google(googleMapsKey);
    List<Address> addresses = await geoCoder.findAddressesFromCoordinates(new Coordinates(latitude, longitude));

    final result = addresses.where((a) => a.locality != null)?.first?.locality;

    return result;  
    } on Exception catch(e) {
      Crashlytics.instance.recordError(e, StackTrace.current);
      return "";
    }
  }
}