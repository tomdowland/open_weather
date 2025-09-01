import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/services/weather_service.dart';

import 'async_fetch_forecast_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LocationCheck>(),
  MockSpec<WeatherService>(),
  MockSpec<WeatherResult>(),
  MockSpec<Position>(),
])
void main() async {
  ProviderContainer createContainer() {
    final container = ProviderContainer.test(
      overrides: [
        locationCheckProvider.overrideWith((ref) {
          return MockLocationCheck();
        }),
        weatherServiceProvider.overrideWith((ref) {
          return MockWeatherService();
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('async_weather test', () {
    test('initialisation test', () async {
      final container = createContainer();

      when(container.read(locationCheckProvider).getLocation()).thenAnswer(
        (_) async => Future<Position>.value(MockPosition()),
      );

      when(
        container
            .read(weatherServiceProvider)
            .getLocalWeather(
              latitude: MockPosition().longitude,
              longitude: MockPosition().latitude,
            ),
      ).thenAnswer(
        (_) async => Future<WeatherResult>.value(MockWeatherResult()),
      );

      await expectLater(
        container.read(asyncWeatherProvider.future),
        completion(isA<MockWeatherResult>()),
      );
    });

    test('initialise and fail location', () async {
      final container = createContainer();
      when(
        container.read(locationCheckProvider).getLocation(),
      ).thenThrow(TimeoutException('timeout'));

      await expectLater(
        container.read(asyncWeatherProvider.future),
        throwsException,
      );
    });

    test('initialise and fail api fetch', () async {
      final container = createContainer();
      when(
        container.read(locationCheckProvider).getLocation(),
      ).thenAnswer(
        (_) async => Future<Position>.value(MockPosition()),
      );

      when(
        container
            .read(weatherServiceProvider)
            .getLocalWeather(
              latitude: MockPosition().longitude,
              longitude: MockPosition().latitude,
            ),
      ).thenThrow(
        DioException.connectionTimeout(
          timeout: Duration.zero,
          requestOptions: RequestOptions(),
        ),
      );

      await expectLater(
        container.read(asyncWeatherProvider.future),
        throwsException,
      );
    });
  });
}
