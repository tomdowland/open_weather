import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/services/retrofit.dart';

import 'fetch_forecast_test.mocks.dart';

@GenerateMocks([RestClient], customMocks: [MockSpec<ForecastData>()])
void main() {
  group('fetchForecast', () {
    test('return 5 day forecast if successful', () async {
      final restClient = MockRestClient();

      when(
        restClient.weatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: 'city',
        ),
      ).thenAnswer((_) async => Future<ForecastData>.value(MockForecastData()));
      expect(
        await restClient.weatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: 'city',
        ),
        isA<ForecastData>(),
      );
    });

    test('throw an exception when error', () async {
      final restClient = MockRestClient();

      when(
        restClient.weatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: ' ',
        ),
      ).thenThrow(
        DioException.badResponse(
          statusCode: 401,
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 401,
            statusMessage: 'Client error - the request contains bad syntax or cannot be fulfilled',
            data: 'Client error - the request contains bad syntax or cannot be fulfilled',
          ),
        ),
      );
      expect( () async => restClient.weatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: ' ',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
