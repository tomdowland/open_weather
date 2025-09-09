// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';

import 'package:open_weather/main.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:open_weather/models/weather_result.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/home_page_provider.dart';
import 'package:open_weather/providers/location_provider.dart';
import 'package:open_weather/repositories/weather_repository.dart';
import 'package:open_weather/services/weather_service.dart';
import 'package:open_weather/ui/pages/home_page.dart';

import 'widget_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AsyncWeather>(),
  MockSpec<WeatherResult>(),
  MockSpec<WeatherService>(),
  MockSpec<WeatherRepository>(),
  MockSpec<LocationCheck>(),
  MockSpec<Position>(),
  MockSpec<CurrentWeather>(),
  MockSpec<ForecastData>(),
])
void main() {
  testWidgets('Search toggle', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [asyncWeatherProvider.overrideWith(MockAsyncWeather.new)],
        child: const HomePage(),
      ),
    );
    final container = tester.container();

    expect(container.read(homePageNotifierProvider).editing, isFalse);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNothing);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(container.read(homePageNotifierProvider).editing, isTrue);
  });

  testWidgets('test navigate Settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [asyncWeatherProvider.overrideWith(MockAsyncWeather.new)],
        child: const MyApp(),
      ),
    );
    expect(find.byIcon(Icons.settings), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.backButton(), findsOneWidget);
    expect(find.text('Settings'), findsOne);
  });
}
