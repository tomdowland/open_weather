import 'package:open_weather/models/full_result_model.dart';
import 'package:open_weather/models/weather_model.dart';
import 'package:open_weather/services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepository(this._apiService);

  Future<WeatherModel?> getWeather(String city) {
    return _apiService.fetchTodayWeather(city);
  }

  Future<List<WeatherModel>?> getForecast(String city) {
    return _apiService.fetchForecast(city);
  }

  Future<WeatherModel?> getLocalWeather({
    required double latitude,
    required double longitude,
  }) {
    return _apiService.getLocalWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
