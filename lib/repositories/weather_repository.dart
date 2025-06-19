import 'package:open_weather/models/weather_model.dart';
import 'package:open_weather/services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepository(this._apiService);

  Future<WeatherModel?> getWeather(String city, {String language = 'en'}) {
    return _apiService.fetchTodayWeather(city, language: language);
  }

  Future<List<WeatherModel>?> getForecast(
    String city, {
    String language = 'en',
  }) {
    return _apiService.fetchForecast(city, language: language);
  }

  Future<WeatherModel?> getLocalWeather({
    required double latitude,
    required double longitude,
    String language = 'en',
  }) {
    return _apiService.getLocalWeather(
      latitude: latitude,
      longitude: longitude,
      language: language,
    );
  }
}
