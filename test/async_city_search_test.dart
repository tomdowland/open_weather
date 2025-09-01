import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/services/weather_service.dart';
import 'async_city_search_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<WeatherService>(),
  MockSpec<WeatherResult>(),
])
void main() async {
  ProviderContainer createContainer() {
    final container = ProviderContainer.test(
      overrides: [
        weatherServiceProvider.overrideWith((ref) {
          return MockWeatherService();
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('string search tests', () {
    test('run city search', () async {
      final container = createContainer();
      final notifier = container.read(asyncWeatherProvider.notifier);
      when(
        container.read(weatherServiceProvider).searchWeather('city'),
      ).thenAnswer(
        (_) async => Future<WeatherResult>.value(MockWeatherResult()),
      );

      await notifier.updateWeather('city');

      await expectLater(
        container.read(asyncWeatherProvider).value,
        isA<MockWeatherResult>(),
      );
    });

    test('fail search bad response', () async {
      final container = createContainer();
      final notifier = container.read(asyncWeatherProvider.notifier);
      when(
        container.read(weatherServiceProvider).searchWeather('city'),
      ).thenThrow(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: RequestOptions(),
          response: Response(requestOptions: RequestOptions()),
        ),
      );

      await notifier.updateWeather('city');

      await expectLater(
        container.read(asyncWeatherProvider).error,
        isA<DioException>(),
      );
    });
  });
}
