import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_five_day_forecast.g.dart';

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
class AsyncFiveDayForecast extends _$AsyncFiveDayForecast {
  @override
  Future<ForecastData?> build() async {
    try {
      final position = ref.watch(locationCheckProvider).value?.position;
      if (position != null) {
        final result = await localForecast(
          position.latitude,
          position.longitude,
        );
        return result;
      } else {
        return null;
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<ForecastData?> searchForecast(String city) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .fetchWeatherForecast(city);
      return result;
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<ForecastData?> localForecast(double lat, double lon) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .getLocalForecast(latitude: lat, longitude: lon);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
