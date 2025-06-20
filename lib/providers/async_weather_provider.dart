import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_weather/models/full_result_model.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'async_weather_provider.g.dart';

// Provider for the API Service (remains a regular Provider)
final weatherApiService = Provider((ref) => WeatherApiService());

// Provider for the Repository (remains a regular Provider)
final weatherRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(weatherApiService);
  return WeatherRepository(apiService);
});

@riverpod
class AsyncWeather extends _$AsyncWeather {
  @override
  Future<FullResult?> build() async {
    // Attempt to fetch current location weather on startup
    try {
      final position = await _determinePosition();
      final repository = ref.read(weatherRepositoryProvider);
      final weather = await repository.getLocalWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final forecast = await ref
          .read(weatherRepositoryProvider)
          .getForecast(weather?.city ?? '');

      return FullResult(
        city: weather?.city,
        country: weather?.country,
        weather: weather?.weather,
        temperature: weather?.temperature,
        dateTime: weather?.dateTime,
        icon: weather?.icon,
        forecast: forecast,
      );
    } on DioException catch (e) {
      // if (e.response == null) {
      rethrow;
      // }
      ;
    }
  }

  // Helper method to determine the current position of the device.
  // It handles location service availability and permission requests.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position.
      return Future.error(
        'Location services are disabled. Please enable them in your device settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again
        return Future.error(
          'Location permissions are denied. Please grant them to get weather for your current location.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions. Please enable them manually in app settings.',
      );
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition();
    } on DioException catch (e) {
      rethrow;
    }
  }

  // Method to fetch weather by city name (can be triggered by user input)
  Future<FullResult?> fetchWeatherByCity(String city) async {
    try {
      final repository = ref.read(weatherRepositoryProvider);
      final weather = await repository.getWeather(city);
      final forecast = await repository.getForecast(city);
      return FullResult(
        city: weather?.city,
        country: weather?.country,
        weather: weather?.weather,
        temperature: weather?.temperature,
        dateTime: weather?.dateTime,
        icon: weather?.icon,
        forecast: forecast,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        rethrow;
      }
    }
  }
}
