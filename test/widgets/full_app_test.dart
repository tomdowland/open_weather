import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/main.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:open_weather/ui/pages/settings_page.dart';
import 'full_app_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RestClient>(),
  MockSpec<Locale>(),
])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter.baseflow.com/geolocator');

  Future<dynamic> methodHandler(MethodCall call) async {
    if (call.method == 'isLocationServiceEnabled') {
      return true;
    }
    if (call.method == 'checkPermission') {
      //return denied
      return 0;
    }
    if (call.method == 'requestPermission') {
      //return allowed
      return 2;
    }
    if (call.method == 'getCurrentPosition') {
      // requires returned data to be in json
      return Future<Map<String, dynamic>>.value(
        Position(
          longitude: 1,
          latitude: 1,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          altitudeAccuracy: 1,
          heading: 1,
          headingAccuracy: 1,
          speed: 1,
          speedAccuracy: 1,
        ).toJson(),
      );
    }
    return null;
  }

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, methodHandler);
    HttpOverrides.global = null;
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('app tests', () {
    ProviderScope createContainer() {
      return ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWith(
            (ref) => WeatherRepository(
              MockLocale().languageCode,
              MockRestClient(),
            ),
          ),
          asyncWeatherProvider.overrideWithBuild((_, weatherProvider) {
            return Future<WeatherResult>.value(
              WeatherResult(
                currentWeatherData: CurrentWeather.dummy(),
                forecastData: ForecastData.dummy(),
              ),
            );
          }),
        ],
        child: const MyApp(),
      );
    }

    testWidgets('settings navigation', (tester) async {
      await tester.pumpWidget(
        createContainer(),
      );

      final settings = find.byIcon(Icons.settings);
      final settingsButton = find.ancestor(
        of: settings,
        matching: find.byType(IconButton),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(settings, findsOneWidget);
      expect(settingsButton, findsOneWidget);
      expect(tester.widget<IconButton>(settingsButton).onPressed, isNotNull);

      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.tap(find.text('日本語'));
      await tester.pump();
      await tester.tap(find.backButton());
      await tester.pumpAndSettle();

      expect(find.backButton(), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.text('都市名を入力して下さい'), findsOneWidget);
    });

    testWidgets('text search', (tester) async {
      await tester.pumpWidget(createContainer());
      final container = tester.container();

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textField = find.byType(TextField);

      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Paris');

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalWeather(city: 'Paris'),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return Future<CurrentWeather>.value(CurrentWeather.dummy());
      });
      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(city: 'Paris'),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return Future<ForecastData>.value(ForecastData.dummy());
      });

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
  });
}
