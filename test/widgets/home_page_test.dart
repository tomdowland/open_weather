import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/retrofit.dart';
import 'package:open_weather/ui/pages/home_page.dart';
import 'home_page_test.mocks.dart';

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
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  MaterialApp createTestContainer() {
    final container = MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ja')],
      home: ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWith(
            (ref) =>
                WeatherRepository(MockLocale().languageCode, MockRestClient()),
          ),
          asyncWeatherProvider.overrideWithBuild(
            (_, asyncWeather) => Future<WeatherResult>.value(
              WeatherResult(
                currentWeatherData: CurrentWeather.dummy(),
                forecastData: ForecastData.dummy(),
              ),
            ),
          ),
        ],
        child: const HomePage(),
      ),
    );

    return container;
  }

  group('app bar tests', () {
    testWidgets('search toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestContainer());

      final search = find.byIcon(Icons.search);
      final gps = find.byIcon(Icons.gps_fixed);
      final cancel = find.byIcon(Icons.cancel);
      final settings = find.byIcon(Icons.settings);
      final textField = find.byType(TextField);

      await tester.pumpAndSettle();

      expect(search, findsOneWidget);
      expect(gps, findsOneWidget);
      expect(cancel, findsNothing);
      expect(settings, findsOneWidget);
      expect(textField, findsNothing);

      await tester.tap(search);
      await tester.pump();

      expect(search, findsNothing);
      expect(gps, findsOneWidget);
      expect(cancel, findsOneWidget);
      expect(settings, findsNothing);
      expect(textField, findsOneWidget);

      await tester.tap(cancel);
      await tester.pump();

      expect(search, findsOneWidget);
      expect(gps, findsOneWidget);
      expect(cancel, findsNothing);
      expect(settings, findsOneWidget);
      expect(textField, findsNothing);
    });

    testWidgets('test gps', (WidgetTester tester) async {
      await tester.pumpWidget(createTestContainer());
      final container = tester.container();

      final gps = find.byIcon(Icons.gps_fixed);
      final gpsButton = find.ancestor(
        of: gps,
        matching: find.byType(IconButton),
      );

      expect(gps, findsOneWidget);
      expect(gpsButton, findsOneWidget);
      expect(tester.widget<IconButton>(gpsButton).onPressed, isNull);

      await tester.pumpAndSettle();

      expect(gps, findsOneWidget);
      expect(tester.widget<IconButton>(gpsButton).onPressed, isNotNull);

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalWeather(latitude: 1, longitude: 1),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return Future<CurrentWeather>.value(CurrentWeather.dummy());
      });
      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(latitude: 1, longitude: 1),
      ).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return Future<ForecastData>.value(ForecastData.dummy());
      });

      await tester.tap(gpsButton);
      await tester.pump();

      expect(tester.widget<IconButton>(gpsButton).onPressed, isNull);

      await tester.pumpAndSettle();

      expect(tester.widget<IconButton>(gpsButton).onPressed, isNotNull);
    });
  });
}
