import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';

@riverpod
class LocationCheck extends _$LocationCheck {
  @override
  Future<Position?> build() async {
    try {
      return await getLocation();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkLocationServicesEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled) {
        return enabled;
      }
      throw const LocationServiceDisabledException();
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationPermission?> checkAndRequestPermission() async {
    try {
      if (await checkLocationServicesEnabled()) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        return permission;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Position?> getLocation() async {
    try {
      await checkAndRequestPermission();
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );

      return position;
    } on Exception {
      rethrow;
    }
  }
}
