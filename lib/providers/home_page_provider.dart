import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/full_result_model.dart';
import 'package:open_weather/providers/async_weather_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_page_provider.freezed.dart';
part 'home_page_provider.g.dart';

@freezed
abstract class FrontPage with _$FrontPage {
  factory FrontPage({
    @Default(false) bool editing,
    required bool isBusy,
    required bool networkError,
    FullResult? weatherResults,
  }) = _FrontPage;
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  FrontPage build() {
    final weather = ref.watch(asyncWeatherProvider);
    try {
      return FrontPage(
        weatherResults: weather.value,
        isBusy: weather.isLoading,
        networkError: weather.hasError,
      );
    } on DioException catch (e) {
      if (e.response == null) {
        return FrontPage(isBusy: false, networkError: weather.hasError);
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
