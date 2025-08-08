import 'package:dio/dio.dart';
import 'package:open_weather/models/weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherApiService {
  final Dio _dio = Dio();

  static const String _url = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'e5d3ccda6cdaa06e3c5c154dc9fc6c94';

  Future<WeatherModel?> fetchTodayWeather(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');
      final response = await _dio.get<Map<String, dynamic>>(
        '$_url/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': language,
        },
      );
      if (response.statusCode == 200) {
        final main = response.data?['main'] as Map;
        final weather = (response.data?['weather']as List)[0]
        as Map<String, dynamic>;

        return WeatherModel(
          city: response.data!['name'].toString(),
          temperature: main['temp'] as double,
          weather: weather['description'] as String,
          icon: weather['icon'] as String,
          dateTime: (response.data!['dt'] as int) * 1000,
        );
      }
      if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<WeatherModel>?> fetchForecast(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');
      final response = await _dio.get<Map<String, List<Map<String, dynamic>>>>(
        '$_url/forecast',
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': 'metric',
          'lang': language,
        },
      );
      if (response.statusCode == 200) {
        final list = response.data!['list'];
        final result = <WeatherModel>[];
        for (var i = 0; i < list!.length - 1; i++) {
          final main = list[i]['main'] as Map<String, dynamic>;
          final weather = (list[i]['weather'] as List)[0]
          as Map<String, String>;
          final dateTime = (list[i]['dt'] as int) * 1000;

          result.add(
            WeatherModel(
              // city: response.data['name'],
              temperature: main['temp'] as double,
              weather: weather['description'] ?? '',
              icon: weather['icon'],
              dateTime: dateTime,
            ),
          );
        }
        return result;
      }
      if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<WeatherModel?> getLocalWeather({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('locale');
      final response = await _dio.get<Map<String, dynamic>>(
        '$_url/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': language,
        },
      );
      if (response.statusCode == 200) {
        final main = response.data!['main'] as Map<String, dynamic>;
        final weather = (response.data!['weather']
        as List<Map<String, String>>)[0];

        return WeatherModel(
          city: response.data!['name'] as String,
          temperature: main['temp'] as double,
          weather: weather['description']!,
          icon: weather['icon'],
          dateTime: (response.data!['dt'] as int) * 1000,
        );
      }
      if (response.statusCode == 404) {
        return null;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
