
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_five_day_forecast.g.dart';

// Provider for the API Service (remains a regular Provider)
final Provider<WeatherApiService> weatherApiService = Provider(
      (ref) => WeatherApiService(),
);

// Provider for the Repository (remains a regular Provider)
final Provider<WeatherRepository> weatherRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(weatherApiService);
  return WeatherRepository(apiService);
});

@riverpod
class AsyncFiveDayForecast extends _$AsyncFiveDayForecast{

  @override
  Future<ForecastData?> build(String? city)async{
    try {
      final result = await ref.read(weatherRepositoryProvider).fetchWeatherForecast(city??'');
      print(result?.city?.name);
      return result;
    } on Exception catch (e) {
      rethrow;
    }
  }

}