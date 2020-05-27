import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:fivekmrun_flutter/private/secrets.dart';

class GoogleMapsService {
  Future<String> getTownFromGeoLocation(double latitude, double longitude) async {
    try {
      Geocoding geoCoder = Geocoder.google(googleMapsKey);
      List<Address> addresses = await geoCoder.findAddressesFromCoordinates(new Coordinates(latitude, longitude));

      if (addresses.any((a) => a.locality != null)) {
        final result = addresses.firstWhere((a) => a.locality != null)?.locality;
        return result; 
      } 
      else {
        return addresses.firstWhere((a) => a.adminArea != null).adminArea;
      }
    } on Exception catch(e) {
      Crashlytics.instance.recordError(e, StackTrace.current);
      return "";
    }
  }
}