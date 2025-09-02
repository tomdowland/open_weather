
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/client_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
  MockSpec<CurrentWeather>(),
  MockSpec<ForecastData>(),
  MockSpec<RestClient>(),
  MockSpec<Locale>()
])
void main() async {
  ProviderContainer createContainer() {
    final restClient = MockRestClient();
    final container = ProviderContainer.test(
      overrides: [
        weatherRepositoryProvider.overrideWith((ref) {
          return WeatherRepository(MockLocale().languageCode, restClient);
        }),
        restClientProvider.overrideWithValue(restClient),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }


  group('run tests on weather repo', () {
    test('test1', () async {
      final container = createContainer();

      when(
        container.read(restClientProvider).currentWeatherSearch(
          units: 'metric',
          language: MockLocale().languageCode,
        ),
      ).thenAnswer(
          (_) => Future<CurrentWeather>.value(MockCurrentWeather()),
      );


      await expectLater(
        container.read(weatherRepositoryProvider).getLocalWeather(),
        completion(isA<MockCurrentWeather>()),
      );
    });
  });
}
