import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/settings_provider.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'weather_api_service.g.dart';

class WeatherApiService {
  WeatherApiService(this.locale);
  final String locale;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  RestClient get client => RestClient(_dio, baseUrl: _url!);
  String? get _apiKey => dotenv.env['API_KEY'];
  String? get _url => dotenv.env['BASE_URL'];

  Future<ForecastData?> searchForecast(String city) async {
    try {
      final response = await client.weatherSearch(
        city: city,
        apiKey: _apiKey!,
        units: 'metric',
        language: locale,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather?> searchCurrentWeather(String city) async {
    try {
      final response = await client.currentWeatherSearch(
        city: city,
        apiKey: _apiKey!,
        units: 'metric',
        language: locale,
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
      final response = await client.currentWeatherSearch(
        lat: latitude,
        lon: longitude,
        apiKey: _apiKey!,
        units: 'metric',
        language: locale,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ForecastData?> getLocalForecast({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await client.weatherSearch(
        lat: latitude,
        lon: longitude,
        apiKey: _apiKey!,
        units: 'metric',
        language: locale,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
WeatherApiService weatherApiService (Ref ref) {
  return WeatherApiService(ref.read(settingsNotifierProvider).locale!.languageCode);
}
