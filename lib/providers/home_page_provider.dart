import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/async_weather_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_page_provider.freezed.dart';
part 'home_page_provider.g.dart';

@freezed
abstract class FrontPage with _$FrontPage {
  factory FrontPage({
    required bool isBusy,
    required bool hasError,
    @Default(false) bool editing,
    String? errorMessage,
    RequestError? errorType,
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
        hasError: asyncWeather.hasError,
        errorType: asyncWeather.value?.errorType,
        errorMessage: asyncWeather.value?.errorMessage,
      );
    } catch (e) {
      print(
        'async error: ${ref.watch(asyncWeatherProvider).hasError ?? 'none'}',
      );
      return FrontPage(
        isBusy: false,
        hasError: asyncWeather.hasError,
        errorType: asyncWeather.value?.errorType,
        errorMessage: asyncWeather.value?.errorMessage,
      );
    }
  }

  Future<void> searchCity(String city) async {
    final asyncWeather = ref.watch(asyncWeatherProvider);
    try {
      state = state.copyWith(isBusy: true, hasError: false);
      final result = await ref
          .read(asyncWeatherProvider.notifier)
          .fetchWeatherByCity(city);
      state = state.copyWith(
        editing: false,
        weatherResults: result?.fiveDayForecast,
        currentWeather: result?.currentWeather,
        errorType: result?.errorType,
        isBusy: false,
        hasError: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = state.copyWith(
          editing: false,
          isBusy: false,
          hasError: true,
          errorType: asyncWeather.value?.errorType,
          errorMessage: '404 exception: ${e.message}',
        );
      } else {
        state = state.copyWith(
          editing: false,
          isBusy: false,
          hasError: false,
          errorType: asyncWeather.value?.errorType,
          errorMessage: 'non 404 exepction ${e.message}',
        );
      }
    }
  }

  void editCity() {
    state = state.copyWith(editing: !state.editing);
  }
}
