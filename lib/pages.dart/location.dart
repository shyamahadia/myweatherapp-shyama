// location.dart

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Request location permission
  Future<void> requestPermission() async {
    var status = await Permission.location.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      throw Exception("Location permission denied");
    }
  }

  // Get the current position (latitude, longitude)
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are denied");
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Convert coordinates to city name
  Future<String> getCityFromCoordinates(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ?? "Unknown";
    } else {
      throw Exception("Unable to get city from coordinates");
    }
  }

  // High-level method to get city directly
  Future<String> getUserCity() async {
    await requestPermission();
    Position position = await getCurrentPosition();
    String city = await getCityFromCoordinates(position);
    return city;
  }
}

