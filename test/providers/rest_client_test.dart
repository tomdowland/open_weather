import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/providers/client_provider.dart';
import 'package:open_weather/services/retrofit.dart';

import 'rest_client_test.mocks.dart';

@GenerateMocks(
  [RestClient],
  customMocks: [
    MockSpec<ForecastData>(),
    MockSpec<CurrentWeather>(),
  ],
)
void main() {
  group('fetchForecast', () {
    final restClient = MockRestClient();

    ProviderContainer createContainer() {
      final container = ProviderContainer.test(
        overrides: [
          restClientProvider.overrideWith((ref) => restClient),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('return 5 day forecast if successful', () async {
      final container = createContainer();

      when(
        restClient.weatherSearch(
          units: 'units',
          language: 'language',
          city: 'city',
        ),
      ).thenAnswer((_) async => Future<ForecastData>.value(MockForecastData()));
      expect(
        await container
            .read(restClientProvider)
            .weatherSearch(
              units: 'units',
              language: 'language',
              city: 'city',
            ),
        isA<MockForecastData>(),
      );
    });

    test('throw a bad response exception', () async {
      final container = createContainer();

      when(
        restClient.weatherSearch(
          units: 'units',
          language: 'language',
          city: ' ',
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(),
        ),
      );

      expect(
        () async => container
            .read(restClientProvider)
            .weatherSearch(
              units: 'units',
              language: 'language',
              city: ' ',
            ),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.badResponse,
          ),
        ),
      );
    });

    test("return today's forecast if successful", () async {
      final container = createContainer();
      when(
        restClient.currentWeatherSearch(
          units: 'units',
          language: 'language',
          city: 'city',
        ),
      ).thenAnswer(
        (_) async => Future<CurrentWeather>.value(MockCurrentWeather()),
      );
      expect(
        await container
            .read(restClientProvider)
            .currentWeatherSearch(
              units: 'units',
              language: 'language',
              city: 'city',
            ),
        isA<CurrentWeather>(),
      );
    });

    test('throw a timeout exception', () async {
      final container = createContainer();

      when(
        restClient.currentWeatherSearch(
          units: 'metric',
          language: 'en',
          city: 'Tokyo',
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () async => container
            .read(restClientProvider)
            .currentWeatherSearch(
              units: 'metric',
              language: 'en',
              city: 'Tokyo',
            ),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });
  });
}
