import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'async_weather_provider.g.dart';
part 'async_weather_provider.freezed.dart';

// Provider for the API Service (remains a regular Provider)
final Provider<WeatherApiService> weatherApiService = Provider(
  (ref) => WeatherApiService(),
);

// Provider for the Repository (remains a regular Provider)
final Provider<WeatherRepository> weatherRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(weatherApiService);
  return WeatherRepository(apiService);
});

@freezed
abstract class AsyncWeatherModel with _$AsyncWeatherModel {
  const factory AsyncWeatherModel({
    ForecastData? fiveDayForecast,
    CurrentWeather? currentWeather,
    String? errorMessage,
    RequestError? errorType,
  }) = _AsyncWeatherModel;
}

@riverpod
class AsyncWeather extends _$AsyncWeather {
  @override
  Future<AsyncWeatherModel?> build() async {
    // Attempt to fetch current location weather on startup
    try {
      final position = await _determinePosition();
      final repository = ref.read(weatherRepositoryProvider);
      final current = await repository.getLocalWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .fetchWeatherForecast(current?.name ?? '');
      return AsyncWeatherModel(
        currentWeather: current,
        fiveDayForecast: forecast,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const AsyncWeatherModel(errorType: RequestError.notFound);
      }
      if (e.response?.statusCode == 400) {
        return const AsyncWeatherModel(errorType: RequestError.networkError);
      }
    } catch (e) {
      if (e.toString().contains('disabled')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationServicesDisabled,
        );
      }
      if (e.toString().contains('LocationPermission.deniedForever')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationPermissionsPermanentlyDenied,
        );
      }
      if (e.toString().contains('timeout')) {
        return const AsyncWeatherModel(
          errorType: RequestError.requestTimeout,
        );
      }
      if (e.toString().contains('LocationPermission.denied')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationPermissionsDenied,
        );
      }

      rethrow;
    }
  }

  // Helper method to determine the current position of the device.
  // It handles location service availability and permission requests.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    const settings = LocationSettings(timeLimit: Duration(seconds: 10));
    print('searching location');
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
      print(e);
      rethrow;
    }
  }

  // Method to fetch weather by city name (can be triggered by user input)
  Future<AsyncWeatherModel?> fetchWeatherByCity(String city) async {
    try {
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .fetchWeatherForecast(city);
      final current = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(city);
      return AsyncWeatherModel(
        fiveDayForecast: forecast,
        currentWeather: current,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const AsyncWeatherModel(errorType: RequestError.notFound);
      }
      if (e.response?.statusCode == 400) {
        return const AsyncWeatherModel(errorType: RequestError.networkError);
      }
      rethrow;
    } catch (e) {
      if (e.toString().contains('disabled')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationServicesDisabled,
        );
      }
      if (e.toString().contains('LocationPermission.deniedForever')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationPermissionsPermanentlyDenied,
        );
      }
      if (e.toString().contains('timeout')) {
        return const AsyncWeatherModel(
          errorType: RequestError.requestTimeout,
        );
      }
      if (e.toString().contains('LocationPermission.denied')) {
        return const AsyncWeatherModel(
          errorType: RequestError.locationPermissionsDenied,
        );
      }

      rethrow;
    }
  }
}
