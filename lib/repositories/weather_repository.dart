import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_gps_weather.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'weather_repository.g.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);
  final WeatherApiService _apiService;

  // try-catches here don't seem to execute
  Future<WeatherResult> searchWeather(String city) async {
    try {
      final forecast = await _apiService.searchForecast(city);
      final current = await _apiService.searchCurrentWeather(city);
      return WeatherResult(
        forecastData: forecast,
        currentWeatherData: current,
      );
    } on Exception catch (e) {
      print('forecast search error: $e');
      rethrow;
    }
  }
  //
  // Future<CurrentWeather?> getCurrentWeather(String city) async {
  //   try {
  //     return await _apiService.searchCurrentWeather(city);
  //   } on Exception catch (e) {
  //     print('current search error: $e');
  //     rethrow;
  //   }
  // }

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
    } on Exception catch (e) {
      print('current gps error: $e');
      rethrow;
    }
  }

  // Future<ForecastData?> getLocalForecast({
  //   required double? latitude,
  //   required double? longitude,
  // }) async {
  //   try {
  //     return await _apiService.getLocalForecast(
  //       latitude: latitude,
  //       longitude: longitude,
  //     );
  //   } on Exception catch (e) {
  //     print('forecast gps error: $e');
  //     rethrow;
  //   }
  // }
}

@riverpod
WeatherRepository weatherRepository (Ref ref){
  final _apiClient;
  return WeatherRepository(WeatherApiService());
}
