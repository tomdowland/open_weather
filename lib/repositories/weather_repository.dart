import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);
  final WeatherApiService _apiService;

  Future<ForecastData?> fetchWeatherForecast([String city = 'Tokyo']) {
    return _apiService.fetchWeatherData(city);
  }

  Future<CurrentWeather?> getCurrentWeather(String city) {
    return _apiService.fetchCurrentWeather(city);
  }

  // Future<List<WeatherModel>?> getForecast(String city) {
  //   return _apiService.fetchForecast(city);
  // }

  Future<CurrentWeather?> getLocalWeather({
    required double latitude,
    required double longitude,
  }) {
    return _apiService.getLocalWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
