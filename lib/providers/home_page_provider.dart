import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/async_gps_weather.dart';
import 'package:open_weather/providers/async_weather_search.dart';
import 'package:open_weather/providers/error_provider.dart';
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
      final asyncGeolocationWeather = ref.watch(asyncGeoLocationWeatherProvider);
      // final asyncForecast = ref.watch(asyncFiveDayForecastProvider);
      // print('from homepage provider forecast ${asyncForecast.error}');
      // print('from homepage provider today ${asyncToday.error}');
      return FrontPage(
        weatherResults: asyncGeolocationWeather.value?.forecastData,
        currentWeather: asyncGeolocationWeather.value?.currentWeatherData,
        isBusy: asyncGeolocationWeather.isLoading,
        hasError: asyncGeolocationWeather.hasError,
        errorType: ref.watch(
          errorHandlerProvider(
            (asyncGeolocationWeather.error ?? Exception()) as Exception,
          ),
        ),
      );
    } on Exception catch (e) {
      print('homepage provider execeptio $e');
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
      final result = await ref.read(asyncWeatherSearchProvider(city).future);
      state = state.copyWith(
        editing: false,
        weatherResults: result?.forecastData,
        currentWeather: result?.currentWeatherData,
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
