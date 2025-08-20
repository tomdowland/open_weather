import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_weather_search.g.dart';

// // Provider for the API Service (remains a regular Provider)
// final Provider<WeatherApiService> weatherApiService = Provider(
//   (ref) => WeatherApiService(),
// );
//
// // Provider for the Repository (remains a regular Provider)
// final Provider<WeatherRepository> weatherRepositoryProvider = Provider((ref) {
//   final apiService = ref.watch(weatherApiService);
//   return WeatherRepository(apiService);
// });

@riverpod
class AsyncWeatherSearch extends _$AsyncWeatherSearch {
  @override
  Future<WeatherResult?> build(String city) async {
    try {
      // final location = await ref.read(locationCheckProvider.future);
      //
      // if (location != null) {
      //   final result = await localForecast(
      //     location.position!.latitude,
      //     location.position!.longitude,
      //   );
        return searchForecast(city);
      // } else {
      //   return null;
      // }
    } on Exception {
      rethrow;
    }
  }

  Future<WeatherResult?> searchForecast(String city) async {
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .searchWeather(city);
      return result;
    } on Exception {
      rethrow;
    }
  }

  // Future<ForecastData?> localForecast(double lat, double lon) async {
  //   try {
  //     final result = await ref
  //         .read(weatherRepositoryProvider)
  //         .getLocalForecast(latitude: lat, longitude: lon);
  //     return result;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
