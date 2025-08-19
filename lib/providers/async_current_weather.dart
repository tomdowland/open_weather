import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_current_weather.g.dart';

// Provider for the API Service (remains a regular Provider)
final Provider<WeatherApiService> weatherApiService = Provider(
  (ref) => WeatherApiService(),
);

// Provider for the Repository (remains a regular Provider)
final Provider<WeatherRepository> weatherRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(weatherApiService);
  return WeatherRepository(apiService);
});

@riverpod
class AsyncCurrentWeather extends _$AsyncCurrentWeather {
  @override
  Future<CurrentWeather?> build() async {
    try {

      final position = ref.watch(locationCheckProvider).value?.position;
      if (position != null) {
        final result = await localCurrentWeather(
          position.latitude,
          position.longitude,
        );
        return result;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather?> searchCurrentWeather(String city) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(city);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather?> localCurrentWeather(double lat, double lon) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .getLocalWeather(latitude: lat, longitude: lon);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
