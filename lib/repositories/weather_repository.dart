import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);
  final WeatherApiService _apiService;

  // try-catches here don't seem to execute
  Future<ForecastData?> fetchWeatherForecast(String city) async {
    try {
      return await _apiService.searchForecast(city);
    } on Exception catch (e) {
      print('forecast search error: $e');
      rethrow;
    }
  }

  Future<CurrentWeather?> getCurrentWeather(String city) async {
    try {
      return await _apiService.searchCurrentWeather(city);
    } on Exception catch (e) {
      print('current search error: $e');
      rethrow;
    }
  }

  Future<CurrentWeather?> getLocalWeather({
    required double? latitude,
    required double? longitude,
  }) async {
    try {
      return await _apiService.getLocalWeather(
        latitude: latitude,
        longitude: longitude,
      );
    } on Exception catch (e) {
      print('current gps error: $e');
      rethrow;
    }
  }

  Future<ForecastData?> getLocalForecast({
    required double? latitude,
    required double? longitude,
  }) async {
    try {
      return await _apiService.getLocalForecast(
        latitude: latitude,
        longitude: longitude,
      );
    } on Exception catch (e) {
      print('forecast gps error: $e');
      rethrow;
    }
  }
}
