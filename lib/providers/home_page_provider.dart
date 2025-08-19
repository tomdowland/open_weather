import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/async_current_weather.dart';
import 'package:open_weather/providers/async_five_day_forecast.dart';
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
    try {
      final asyncToday = ref.watch(asyncCurrentWeatherProvider);
      final asyncForecast = ref.watch(asyncFiveDayForecastProvider);
        return FrontPage(
          weatherResults: asyncForecast.value,
          currentWeather: asyncToday.value,
          isBusy: asyncForecast.isLoading || asyncToday.isLoading,
          hasError: asyncForecast.hasError || asyncToday.hasError,
          // errorType: asyncWeather.value?.errorType,
          // errorMessage: asyncWeather.value?.errorMessage,
        );
    } on Exception catch (e) {
      return FrontPage(
        isBusy: false,
        hasError: true,
        errorType: RequestError.networkError,
        errorMessage: e.toString(),
      );
    }
  }



  Future<void> searchCity(String city) async {
    try {
      state = state.copyWith(isBusy: true, hasError: false);
      final forecast = await ref
          .read(asyncFiveDayForecastProvider.notifier)
          .searchForecast(city);
      final today = await ref
          .read(asyncCurrentWeatherProvider.notifier)
          .searchCurrentWeather(city);
      state = state.copyWith(
        editing: false,
        weatherResults: forecast,
        currentWeather: today,
        // errorType: result?.errorType,
        isBusy: false,
        hasError: false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = state.copyWith(
          editing: false,
          isBusy: false,
          hasError: true,
          errorType: RequestError.notFound,
        );
      } else {
        state = state.copyWith(
          editing: false,
          isBusy: false,
          hasError: true,
          // errorType: asyncWeather.value?.errorType,
        );
      }
      rethrow;
    }
  }

  void editCity() {
    state = state.copyWith(editing: !state.editing);
  }
}
