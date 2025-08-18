import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:open_weather/providers/async_weather_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([AsyncWeather], customMocks: [MockSpec<AsyncWeatherModel>()])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;
  await dotenv.load();
  ProviderContainer createContainer() {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    return container;
  }

  group('async_fetch_forecast startup', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/geolocator'),
            (MethodCall call) async {
              if (call.method == 'getCurrentPosition') {
                return <String, dynamic>{
                  'latitude': 37.7749,
                  'longitude': -122.4194,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'accuracy': 10.0,
                  'altitude': 0.0,
                  'heading': 0.0,
                  'speed': 0.0,
                  'speedAccuracy': 0.0,
                };
              }
              if (call.method == 'isLocationServiceEnabled') {
                return true;
              }
              // returns permission granted
              return 2;
            },
          );
      SharedPreferences.setMockInitialValues({'locale': 'en'});
    });

    test('return forecast if successful', () async {
      final container = createContainer();
      final subscription = container.listen(
        asyncWeatherProvider.future,
        (_, __) {},
      );

      await expectLater(
        subscription.read(),
        completion(isA<AsyncWeatherModel>()),
      );
    });

    test('city search', () async {
      final container = createContainer();
      final subscription = container.listen(
        asyncWeatherProvider.future,
        (_, __) {},
      );
      await container
          .read(asyncWeatherProvider.notifier)
          .fetchWeatherByCity('Tokyo');

      await expectLater(
        // container.read(asyncWeatherProvider.future),
        container
            .read(asyncWeatherProvider.notifier)
            .fetchWeatherByCity('Tokyo'),
        completion(isA<AsyncWeatherModel>()),
      );

      await container
          .read(asyncWeatherProvider.notifier)
          .fetchWeatherByCity('q');

      expect(
        subscription.read().then((_)=> container.read(asyncWeatherProvider.notifier).fetchWeatherByCity('q')),
        completion(const AsyncWeatherModel(errorType: RequestError.notFound)),
      );
    });
  });
}
