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
      await searchWeather(searchedCity!);
      return state.value;
    } else {
      await locationWeather();
      return state.value;
    }
  }

  Future<void> locationWeather() async {
    state = const AsyncValue.loading();
    if (state.isReloading) {
      ref.invalidate(locationCheckProvider);
    }
    final location = await AsyncValue.guard(() async {
      final result = await ref.watch(locationCheckProvider.future);
      return result;
    });
    if (location.value != null) {
      state = await AsyncValue.guard(() async {
        final result = await ref
            .read(weatherServiceProvider)
            .getLocalWeather(
              latitude: location.value?.latitude,
              longitude: location.value?.longitude,
            );
        return result;
      });
    } else {
      throw location.error! as Exception;
    }
  }

  Future<void> searchWeather(String city) async {
    searchedCity = city;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(weatherServiceProvider).searchWeather(city);
      return result;
    });
  }
}
