import 'package:flutter/material.dart';
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
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/services/weather_service.dart';
import 'package:open_weather/ui/pages/home_page.dart';
import 'home_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AsyncWeather>(),
  MockSpec<WeatherResult>(),
  MockSpec<LocationCheck>(),
  MockSpec<Position>(),
  MockSpec<WeatherService>(),
])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('appBar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ja')],
        home: ProviderScope(
          overrides: [
            locationCheckProvider.overrideWith((ref) => MockLocationCheck()),
            weatherServiceProvider.overrideWith((ref) => MockWeatherService()),
            asyncWeatherProvider.overrideWithBuild(
              (_, __) => Future<WeatherResult>.value(
                WeatherResult(
                  currentWeatherData: CurrentWeather.dummy(),
                  forecastData: ForecastData.dummy(),
                ),
              ),
            ),
          ],
          child: const HomePage(),
        ),
      ),
    );
    final container = tester.container();
    final mockLocation = MockPosition();

    when(
      await container.read(locationCheckProvider).getLocation(),
    ).thenReturn(
      mockLocation,
    );

    when(
      await container
          .read(weatherServiceProvider)
          .getLocalWeather(
            latitude: mockLocation.latitude,
            longitude: mockLocation.longitude,
          ),
    ).thenReturn(
      WeatherResult(
        forecastData: ForecastData.dummy(),
        currentWeatherData: CurrentWeather.dummy(),
      ),
    );

    final gps = find.byIcon(Icons.gps_fixed);
    final settings = find.byIcon(Icons.settings);
    final search = find.byIcon(Icons.search);
    final cancel = find.byIcon(Icons.cancel);

    expect(gps, findsOneWidget);
    expect(settings, findsOneWidget);
    expect(search, findsOneWidget);
    expect(cancel, findsNothing);

    await tester.pumpAndSettle();

    expect(gps, findsOneWidget);
    expect(settings, findsOneWidget);
    expect(search, findsOneWidget);
    expect(cancel, findsNothing);

    await tester.tap(search);
    await tester.pump();

    expect(gps, findsOneWidget);
    expect(settings, findsNothing);
    expect(search, findsNothing);
    expect(cancel, findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(cancel);
    await tester.pump();

    expect(gps, findsOneWidget);
    expect(settings, findsOneWidget);
    expect(search, findsOneWidget);
    expect(cancel, findsNothing);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(search);
    await tester.pump();
    await tester.tap(gps);
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
  });
}
