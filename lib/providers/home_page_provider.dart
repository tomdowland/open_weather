import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/async_weather_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_page_provider.freezed.dart';
part 'home_page_provider.g.dart';

@freezed
abstract class FrontPage with _$FrontPage {
  factory FrontPage({
    required bool isBusy,
    required bool networkError,
    @Default(false) bool editing,
    ForecastData? weatherResults,
    CurrentWeather? currentWeather,
  }) = _FrontPage;
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  FrontPage build() {
    final asyncWeather = ref.watch(asyncWeatherProvider);
    try {
      return FrontPage(
        weatherResults: asyncWeather.value?.fiveDayForecast,
        currentWeather: asyncWeather.value?.currentWeather,
        isBusy: asyncWeather.isLoading,
        networkError: asyncWeather.hasError,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        return FrontPage(isBusy: false, networkError: asyncWeather.hasError);
      } else {
        return FrontPage(isBusy: false, networkError: false);
      }
    }
  }

  Future<void> searchCity(String city) async {
    try {
      state = state.copyWith(isBusy: true, networkError: false);
      final result = await ref
          .read(asyncWeatherProvider.notifier)
          .fetchWeatherByCity(city);
      state = state.copyWith(
        editing: false,
        weatherResults: result,
        isBusy: false,
        networkError: false,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        state = state.copyWith(
          editing: false,
          isBusy: false,
          networkError: true,
        );
      }
    }
  }

  void editCity() {
    state = state.copyWith(editing: !state.editing);
  }
}
