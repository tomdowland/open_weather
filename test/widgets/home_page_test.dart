import 'dart:async';

import 'package:dio/dio.dart';
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
import 'package:open_weather/ui/widgets/forecast_list.dart';
import 'package:open_weather/ui/widgets/today_weather.dart';
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

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);

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

      expect(find.byType(TextField), findsNothing);
      expect(tester.widget<IconButton>(gpsButton).onPressed, isNull);

      await tester.pumpAndSettle();

      expect(tester.widget<IconButton>(gpsButton).onPressed, isNotNull);
    });
  });

  group('page tests', () {
    testWidgets('description', (tester) async {
      await tester.pumpWidget(createTestContainer());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Current Weather'), findsNothing);
      expect(find.text('Weather Forecast'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Current Weather'), findsOneWidget);
      expect(find.text('Weather Forecast'), findsOneWidget);
      expect(find.byType(TodayWeather), findsOneWidget);
      expect(find.byType(ForecastList), findsOneWidget);
      expect(
        tester
            .widget<ForecastList>(find.byType(ForecastList))
            .forecastData
            .weatherList
            ?.length,
        40,
      );
    });
  });

  group('exceptions', () {
    testWidgets('fail and show timeout error', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(latitude: 1, longitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sorry, your request timed out.'),
        findsOneWidget,
      );
      expect(find.text('RETRY'), findsOneWidget);
    });

    testWidgets('fail and show not found', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(latitude: 1, longitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 404,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sorry, no results found'),
        findsOneWidget,
      );
    });

    testWidgets('location time out', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(TimeoutException(''));

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sorry, your request timed out.'),
        findsOneWidget,
      );
    });

    testWidgets('something went wrong', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 400,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Something went wrong'),
        findsOneWidget,
      );
    });

    testWidgets('location service disabled', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(const LocationServiceDisabledException());

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Location services are disabled'),
        findsOneWidget,
      );
    });

    testWidgets('location permission denied', (tester) async {
      await tester.pumpWidget(createTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(const PermissionDeniedException(''));

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Location permissions are denied'),
        findsOneWidget,
      );
    });
  });

  group('japanese exceptions', () {
    MaterialApp createJpTestContainer() {
      final container = MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ja')],
        locale: const Locale('ja'),
        home: ProviderScope(
          overrides: [
            weatherRepositoryProvider.overrideWith(
              (ref) => WeatherRepository(
                MockLocale().languageCode,
                MockRestClient(),
              ),
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

    testWidgets('fail and show timeout error jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(latitude: 1, longitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('タイムアウトしました'),
        findsOneWidget,
      );
      expect(find.text('リトライ'), findsOneWidget);
    });

    testWidgets('fail and show not found jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(latitude: 1, longitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 404,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('見つかりませんでした'),
        findsOneWidget,
      );
    });

    testWidgets('location time out jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(TimeoutException(''));

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('タイムアウトしました'),
        findsOneWidget,
      );
    });

    testWidgets('something went wrong jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 400,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('ネットワークエラーが発生しました'),
        findsOneWidget,
      );
    });

    testWidgets('location service disabled jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(const LocationServiceDisabledException());

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('位置情報サービスが無効です'),
        findsOneWidget,
      );
    });

    testWidgets('location permission denied jp', (tester) async {
      await tester.pumpWidget(createJpTestContainer());

      final container = tester.container();

      await tester.pumpAndSettle();

      when(
        container
            .read(weatherRepositoryProvider)
            .getLocalForecast(longitude: 1, latitude: 1),
      ).thenThrow(const PermissionDeniedException(''));

      await tester.tap(find.byIcon(Icons.gps_fixed));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('位置情報の許可が拒否されました'),
        findsOneWidget,
      );
    });
  });
}
