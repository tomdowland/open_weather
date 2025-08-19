import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<bool> checkLocationServicesEnabled()async{
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }

  Future<LocationPermission> checkAndRequestPermission() async {
    if (await checkLocationServicesEnabled()) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    }else{
      return LocationPermission.unableToDetermine;
    }
  }

  Future<Position?> getLocation() async {
    final permission = await checkAndRequestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
    }
    // TODO_handle location error
    return null;
  }
}
