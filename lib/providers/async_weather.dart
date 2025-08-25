import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/services/weather_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_weather.g.dart';

@riverpod
class AsyncWeather extends _$AsyncWeather {
  String? searchedCity;
  @override
  Future<WeatherResult?> build() async {
    try {
      if (searchedCity != null) {
        await searchWeather(searchedCity!);
        return WeatherResult(
          currentWeatherData: state.value?.currentWeatherData,
          forecastData: state.value?.forecastData,
        );
      } else {
        await locationWeather();
        return WeatherResult(
          currentWeatherData: state.value?.currentWeatherData,
          forecastData: state.value?.forecastData,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> locationWeather() async {
    state = const AsyncValue.loading();
    try {
      if (state.isReloading) {
        ref.invalidate(locationCheckProvider);
      }
      final location = await ref.watch(locationCheckProvider.future);
      if (location != null) {
        final result = await ref
            .read(weatherServiceProvider)
            .getLocalWeather(
              latitude: location.position!.latitude,
              longitude: location.position!.longitude,
            );
        state = AsyncData(result);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> searchWeather(String city) async {
    try {
      searchedCity = city;
      state = const AsyncValue.loading();
      final result = await ref.read(weatherServiceProvider).searchWeather(city);
      state = AsyncData(result);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
