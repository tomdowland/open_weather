import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_service.dart';
import 'weather_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CurrentWeather>(),
  MockSpec<ForecastData>(),
  MockSpec<WeatherResult>(),
  MockSpec<WeatherRepository>(),
  MockSpec<Locale>(),
])
void main() async {
  ProviderContainer createContainer() {
    final mockWeatherRepo = MockWeatherRepository();
    final container = ProviderContainer.test(
      overrides: [
        weatherRepositoryProvider.overrideWith((ref) => mockWeatherRepo),
        weatherServiceProvider.overrideWith(
          (ref) => WeatherService(
            mockWeatherRepo,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('weather service test', () {
    test('get location successfully', () async {
      final container = createContainer();

      // when(
      //   container
      //       .read(weatherRepositoryProvider)
      //       .getLocalWeather(longitude: 0, latitude: 0),
      // ).thenAnswer((_) => Future<CurrentWeather>.value(MockCurrentWeather()));

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 0, latitude: 0),
      ).thenAnswer((_) => Future<ForecastData>.value(MockForecastData()));

      final result = await container
          .read(weatherServiceProvider)
          .getLocalWeather(
        latitude: 0,
        longitude: 0,
      );

        expect(
         result.forecastData,
       isA<MockForecastData>(),
      );
    });

    test('throw timeout exception', () async {
      final container = createContainer();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalWeather(longitude: 0, latitude: 0),
      ).thenAnswer((_) => Future<CurrentWeather>.value(MockCurrentWeather()));

      when(
        await container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 0, latitude: 0),
      ).thenThrow(TimeoutException('message'));

      await expectLater(
        container
            .read(weatherServiceProvider)
            .getLocalWeather(
              latitude: 0,
              longitude: 0,
            ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
