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
    bool? isBusy,
    FullResult? weatherResults,
  }) = _FrontPage;
}

@riverpod
class HomePageNotifier extends _$HomePageNotifier {
  @override
  FrontPage build() {
    final weather = ref.watch(asyncWeatherProvider);
    return FrontPage(weatherResults: weather.value, isBusy: weather.isLoading);
  }

  Future<void> searchCity(String city) async {
    final result = await ref
        .read(asyncWeatherProvider.notifier)
        .fetchWeatherByCity(city);
    state = state.copyWith(
      editing: false,
      weatherResults: result,
      isBusy: false,
    );
  }

  void editCity() {
    state = state.copyWith(editing: !state.editing);
  }
}
