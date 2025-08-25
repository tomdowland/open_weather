import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'weather_service.g.dart';

class WeatherService {
  WeatherService(this._repoService);
  final WeatherRepository _repoService;

  Future<WeatherResult> searchWeather(String city) async {
    try {
      final forecast = await _repoService.searchForecast(city);
      final current = await _repoService.searchCurrentWeather(city);
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
      final current = await _repoService.getLocalWeather(
        latitude: latitude,
        longitude: longitude,
      );
      final forecast = await _repoService.getLocalForecast(
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
WeatherService weatherService(Ref ref) {
  return WeatherService(ref.read(weatherRepositoryProvider));
}
