import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';

@riverpod
class LocationCheck extends _$LocationCheck {
  @override
  Future<Position?> build() async {
    final result = await getLocation();
    return result;
  }

  Future<bool> checkLocationServicesEnabled() async {
    final enabled = await AsyncValue.guard(() async {
      final result = await Geolocator.isLocationServiceEnabled();
      return result;
    });
    if (enabled.value!) {
      return enabled.value!;
    }
    throw const LocationServiceDisabledException();
  }

  Future<LocationPermission?> checkAndRequestPermission() async {
    if (await checkLocationServicesEnabled()) {
      var permission = await AsyncValue.guard(() async {
        final result = await Geolocator.checkPermission();
        return result;
      });
      if (permission.value == LocationPermission.denied) {
        permission = await AsyncValue.guard(() async {
          final result = await Geolocator.requestPermission();
          return result;
        });
      }
      return permission.value;
    }
    return null;
  }

  Future<Position?> getLocation() async {
    await checkAndRequestPermission();
    final position = await AsyncValue.guard(() async {
      final result = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
      return result;
    });

    return position.value;
  }
}
