import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'location_provider.g.dart';
part 'location_provider.freezed.dart';

@freezed
abstract class GeoLocationModel with _$GeoLocationModel {
  const factory GeoLocationModel({
    bool? locationServicesEnabled,
    Position? position,
    LocationPermission? permissionStatus,
    RequestError? error,
  }) = _GeoLocationModel;
}

@riverpod
class LocationCheck extends _$LocationCheck {
  @override
  Future<GeoLocationModel?> build() async {
    try {
      return GeoLocationModel(
        permissionStatus: await checkAndRequestPermission(),
        locationServicesEnabled: await checkLocationServicesEnabled(),
        position: await getLocation(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkLocationServicesEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (enabled) {
      return enabled;
    }
    throw const LocationServiceDisabledException();
  }

  Future<LocationPermission> checkAndRequestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position?> getLocation() async {
    try {
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
