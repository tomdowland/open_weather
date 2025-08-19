import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';
part 'location_provider.freezed.dart';

@freezed
abstract class GeoLocationModel with _$GeoLocationModel {
  const factory GeoLocationModel({
    required bool locationServicesEnabled,
    Position? position,
    LocationPermission? permissionStatus,
  }) = _GeoLocationModel;
}

@riverpod
class LocationCheck extends _$LocationCheck {
  @override
  Future<GeoLocationModel> build() async {
    final locationServicesEnabled = await checkLocationServicesEnabled();
    print('services enabled: $locationServicesEnabled');
    LocationPermission? permission;
    Position? position;

    if (locationServicesEnabled) {
      permission = await checkAndRequestPermission();
      print('permission: $permission');
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      position = await getLocation();
      print('position: $position');
    }

    return GeoLocationModel(
      locationServicesEnabled: locationServicesEnabled,
      permissionStatus: permission,
      position: position,
    );
  }

  Future<bool> checkLocationServicesEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }

  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position?> getLocation() async {
    // final permission = await checkAndRequestPermission();
    // if (permission == LocationPermission.always ||
    //     permission == LocationPermission.whileInUse) {
    final position =  await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 10),
      ),
    );
    return position;
  }
  // TODO_handle location error
  // return null;
  // }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    const settings = LocationSettings(timeLimit: Duration(seconds: 10));
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled,
      // don't continue accessing the position.
      return Future.error(
        'Location services are disabled.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could
        // try requesting permissions again
        return Future.error(
          'LocationPermission.denied',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'LocationPermission.deniedForever',
      );
    }

    // When we reach here, permissions are granted and we can continue accessing
    // the position of the device.
    try {
      return await Geolocator.getCurrentPosition(locationSettings: settings);
    } catch (e) {
      rethrow;
    }
  }
}
