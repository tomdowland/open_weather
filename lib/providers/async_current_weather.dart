
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_current_weather.g.dart';

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
class AsyncCurrentWeather extends _$AsyncCurrentWeather{

  @override
  Future<CurrentWeather?> build(String? city)async{
    try {
      final result = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(city ?? '');
      print(result?.name);
      return result;
    }catch(e){
      rethrow;
    }
  }

}
