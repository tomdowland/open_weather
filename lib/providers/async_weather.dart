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
    if (searchedCity != null) {
      return searchWeather();
    } else {
      return locationWeather();
    }
  }

  Future<WeatherResult?> locationWeather() async {
    state = const AsyncValue.loading();
    if (state.isReloading) {
      ref.invalidate(locationCheckProvider);
    }
    final location = await ref.read(locationCheckProvider).getLocation();
    final result = await ref
        .read(weatherServiceProvider)
        .getLocalWeather(
          latitude: location.latitude,
          longitude: location.longitude,
        );
    return result;
  }

  Future<WeatherResult?> searchWeather() async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(weatherServiceProvider)
        .searchWeather(searchedCity!);
    return result;
  }

  Future<void> getNewLocationWeather() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final location = await ref.read(locationCheckProvider).getLocation();
      final result = await ref
          .read(weatherServiceProvider)
          .getLocalWeather(
            latitude: location.latitude,
            longitude: location.longitude,
          );
      return result;
    });
    searchedCity = null;
  }

  Future<void> updateWeather(String city) async {
    state = const AsyncValue.loading();
    searchedCity = city;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(weatherServiceProvider).searchWeather(city);
      return result;
    });
  }
}
