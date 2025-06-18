import 'package:dio/dio.dart';
import 'package:open_weather/models/weather_model.dart';

class WeatherApiService {
  final Dio _dio = Dio();

  static const String _url = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'e5d3ccda6cdaa06e3c5c154dc9fc6c94';

  Future<WeatherModel?> fetchTodayWeather(String city) async {
    try {
      final response = await _dio.get(
        '$_url/weather',
        queryParameters: {'q': city, 'appid': _apiKey, 'units': 'metric'},
      );
      if (response.data != null) {
        final main = response.data['main'];
        final weather = response.data['weather'][0];

        return WeatherModel(
          city: response.data['name'],
          temperature: main['temp'].toDouble(),
          weather: weather['description'],
          icon: weather['icon'],
          dateTime: response.data['dt'] * 1000,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WeatherModel>?> fetchForecast(String cityName) async {
    try {
      final response = await _dio.get(
        '$_url/forecast',
        queryParameters: {'q': cityName, 'appid': _apiKey, 'units': 'metric'},
      );
      if (response.data != null) {
        final list = response.data['list'];
        final result = <WeatherModel>[];
        for (var i = 0; i < list.length - 1; i++) {
          final main = list[i]['main'];
          final weather = list[i]['weather'][0];
          final dateTime = list[i]['dt'] * 1000;

          result.add(
            WeatherModel(
              // city: response.data['name'],
              temperature: main['temp'].toDouble(),
              weather: weather['description'],
              icon: weather['icon'],
              dateTime: dateTime,
            ),
          );
        }
        return result;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherModel?> getLocalWeather({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.get(
        '$_url/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric', // Or 'imperial'
        },
      );
      if (response.data != null) {
        final main = response.data['main'];
        final weather = response.data['weather'][0];

        return WeatherModel(
          city: response.data['name'],
          temperature: main['temp'].toDouble(),
          weather: weather['description'],
          icon: weather['icon'],
          dateTime: response.data['dt'] * 1000,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
