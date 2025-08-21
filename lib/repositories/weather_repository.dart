import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'weather_repository.g.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);
  final WeatherApiService _apiService;

  Future<WeatherResult> searchWeather(String city) async {
    try {
      final forecast = await _apiService.searchForecast(city);
      final current = await _apiService.searchCurrentWeather(city);
      return WeatherResult(
        forecastData: forecast,
        currentWeatherData: current,
      );
    } on Exception {
      rethrow;
    }
  }

  Future<WeatherResult?> getLocalWeather({
    required double? latitude,
    required double? longitude,
  }) async {
    try {
      final current = await _apiService.getLocalWeather(
        latitude: latitude,
        longitude: longitude,
      );
      final forecast = await _apiService.getLocalForecast(
        latitude: latitude,
        longitude: longitude,
      );
      return WeatherResult(
        currentWeatherData: current,
        forecastData: forecast,
      );
    } on Exception {
      rethrow;
    }
  }
}

@riverpod
WeatherRepository weatherRepository(Ref ref) {
  return WeatherRepository(WeatherApiService());
}
