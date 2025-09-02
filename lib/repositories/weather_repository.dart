import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/client_provider.dart';
import 'package:open_weather/providers/locale_provider.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'weather_repository.g.dart';

class WeatherRepository {
  WeatherRepository(this.locale, this.client);
  final String locale;
  final RestClient client;

  Future<CurrentWeather?> getLocalWeather({
    double? latitude,
    double? longitude,
    String? city,
  }) async {
    try {
      final response = await client.currentWeatherSearch(
        lat: latitude,
        lon: longitude,
        city: city,
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
    String? city,
  }) async {
    try {
      final response = await client.weatherSearch(
        lat: latitude,
        lon: longitude,
        city: city,
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
WeatherRepository weatherRepository(Ref ref) {
  return WeatherRepository(
    ref.read(localeSettingProvider).locale.languageCode,
    ref.read(restClientProvider),
  );
}
