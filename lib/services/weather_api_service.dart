import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherApiService {
  final Dio _dio = Dio();
  RestClient get client => RestClient(_dio, baseUrl: _url!);
  String? get _apiKey => dotenv.env['API_KEY'];
  String? get _url => dotenv.env['BASE_URL'];

  Future<ForecastData?> fetchWeatherData(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');

      final response = await client.weatherSearch(
        city: city,
        apiKey: _apiKey!,
        units: 'metric',
        language: language!,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather?> fetchCurrentWeather(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');
      final response = await client.currentWeatherSearch(
        city: city,
        apiKey: _apiKey!,
        units: 'metric',
        language: language!,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather?> getLocalWeather({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');
      final response = await client.currentWeatherSearch(
        lat: latitude,
        lon: longitude,
        apiKey: _apiKey!,
        units: 'metric',
        language: language!,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
