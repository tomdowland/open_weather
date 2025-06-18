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

// AsyncNotifier for managing the weather state using Riverpod code generation
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
    } catch (e, st) {
      print('Error fetching initial location weather: $e');
      // If location or initial fetch fails, you might want to:
      // 1. Return null and show a message to the user to enter a city.
      // 2. Re-throw the error to set the provider's state to AsyncError.
      // For now, we'll re-throw to clearly indicate an issue.
      AsyncValue.error(e, st);
      rethrow;
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
    return await Geolocator.getCurrentPosition();
  }

  // Method to fetch weather by city name (can be triggered by user input)
  Future<FullResult?> fetchWeatherByCity(String city) async {
    // state = const AsyncValue.loading();
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
    } catch (e) {
      rethrow;
    }
  }

  // Method to re-fetch weather for current location (e.g., refresh button)
  // Future<void> refreshCurrentLocationWeather() async {
  //   state = const AsyncValue.loading();
  //   try {
  //     final position = await _determinePosition();
  //     final repository = ref.read(weatherRepositoryProvider);
  //     final weather = await repository.getWeatherByCoordinates(position.latitude, position.longitude);
  //     state = AsyncValue.data(weather);
  //   } catch (e, st) {
  //     state = AsyncValue.error(e, st);
  //   }
  // }
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:open_weather/models/full_result_model.dart';
// import 'package:open_weather/models/weather_model.dart';
// import 'package:open_weather/repositories/weather_repository.dart';
// import 'package:open_weather/services/weather_api_service.dart';
//
// final weatherApiService = Provider((ref) => WeatherApiService());
//
// // Provider for the Repository
// final weatherRepositoryProvider = Provider((ref) {
//   final apiService = ref.watch(weatherApiService);
//   return WeatherRepository(apiService);
// });
//
// // StateNotifierProvider for managing the weather state
// // This provider will hold the current weather data, loading, and error states.
// final weatherProvider =
//     StateNotifierProvider.autoDispose<WeatherNotifier, AsyncValue<FullResult?>>(
//       (ref) {
//         final repository = ref.watch(weatherRepositoryProvider);
//         return WeatherNotifier(repository);
//       },
//     );
//
// class WeatherNotifier extends StateNotifier<AsyncValue<FullResult?>> {
//   final WeatherRepository _repository;
//
//   WeatherNotifier(this._repository)
//     : super(const AsyncValue.data(null)); // Initial state is null data
//
//   Future<void> fetchWeather(String? city) async {
//     state = const AsyncValue.loading(); // Set state to loading
//     try {
//       final weather = await _repository.getWeather(city ?? 'London,uk');
//       final forecast = await _repository.getForecast(city ?? 'London,uk');
//       final result = FullResult(
//         city: weather?.city,
//         country: weather?.country,
//         weather: weather?.weather,
//         temperature: weather?.temperature,
//         dateTime: weather?.dateTime,
//         icon: weather?.icon,
//         forecast: forecast,
//       );
//       state = AsyncValue.data(result); // Set state to data on success
//     } catch (e, st) {
//       state = AsyncValue.error(e, st); // Set state to error on failure
//     }
//   }
// }
//
// final forecastProvider =
//     StateNotifierProvider.autoDispose<
//       ForecastNotifier,
//       AsyncValue<List<WeatherModel>?>
//     >((ref) {
//       final repository = ref.watch(weatherRepositoryProvider);
//       return ForecastNotifier(repository);
//     });
//
// class ForecastNotifier extends StateNotifier<AsyncValue<List<WeatherModel>?>> {
//   final WeatherRepository _repository;
//
//   ForecastNotifier(this._repository) : super(const AsyncValue.data(null));
// }
