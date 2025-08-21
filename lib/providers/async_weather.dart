import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'async_weather.g.dart';

@riverpod
class AsyncWeather extends _$AsyncWeather {
  @override
  Future<WeatherResult?> build() async {
    try {
      final result = await locationWeather();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherResult?> locationWeather() async {
    try {
      final location = await ref.watch(locationCheckProvider.future);
      if (location != null) {
        final result = await ref
            .read(weatherRepositoryProvider)
            .getLocalWeather(
              latitude: location.position!.latitude,
              longitude: location.position!.longitude,
            );
        return result;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> searchWeather(String city) async {
    try {
      state = const AsyncValue.loading();
      final result = await ref
          .read(weatherRepositoryProvider)
          .searchWeather(city);
      state = AsyncData(result);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
