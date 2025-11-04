import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class LocationService {
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String> getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get timezone based on location (simplified)
  String getTimezoneFromLocation(double latitude, double longitude) {
    // Indonesia timezones based on approximate longitude
    if (longitude >= 95 && longitude < 105) {
      return 'WIB'; // Western Indonesia Time (UTC+7)
    } else if (longitude >= 105 && longitude < 120) {
      return 'WITA'; // Central Indonesia Time (UTC+8)
    } else if (longitude >= 120 && longitude <= 141) {
      return 'WIT'; // Eastern Indonesia Time (UTC+9)
    }
    return 'WIB'; // Default
  }

  int getTimezoneOffset(String timezone) {
    switch (timezone) {
      case 'WIB':
        return 7;
      case 'WITA':
        return 8;
      case 'WIT':
        return 9;
      default:
        return 7;
    }
  }
}
