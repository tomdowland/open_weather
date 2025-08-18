import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/services/retrofit.dart';

import 'fetch_today_test.mocks.dart';

@GenerateMocks([RestClient], customMocks: [MockSpec<CurrentWeather>()])
void main() {
  group('fetchCurrentWeather', () {
    test("return today's forecast if successful", () async {
      final restClient = MockRestClient();

      when(
        restClient.currentWeatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: 'city',
        ),
      ).thenAnswer(
        (_) async => Future<CurrentWeather>.value(MockCurrentWeather()),
      );
      expect(
        await restClient.currentWeatherSearch(
          apiKey: 'apiKey',
          units: 'units',
          language: 'language',
          city: 'city',
        ),
        isA<CurrentWeather>(),
      );
    });

    test('throw an exception when error', () async {
      final restClient = MockRestClient();

      when(
        restClient.currentWeatherSearch(
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
            statusMessage:
                'Client error - the request contains bad syntax or cannot be fulfilled',
            data:
                'Client error - the request contains bad syntax or cannot be fulfilled',
          ),
        ),
      );
      expect(
        () async => restClient.currentWeatherSearch(
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
