import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';

class LocationCheck {
  Future<bool> checkLocationServicesEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) {
      return enabled;
    }
    throw const LocationServiceDisabledException();
  }

  Future<LocationPermission?> checkAndRequestPermission() async {
    if (await checkLocationServicesEnabled()) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    }
    return null;
  }

  Future<Position> getLocation() async {
    await checkAndRequestPermission();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 10),
      ),
    );
    return position;
  }
}

@riverpod
LocationCheck locationCheck(Ref ref) {
  return LocationCheck();
}
