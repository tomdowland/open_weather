import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:open_weather/main.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/ui/pages/settings_page.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();



  group('app tests', () {
    ProviderScope createContainer() {
      return const ProviderScope(
        child: MyApp(),
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

      // await tester.tap(find.text('English'));
      // await tester.pump();
      // await tester.tap(find.text('日本語'));
      // await tester.pump();
      await tester.tap(find.backButton());
      await tester.pumpAndSettle();

      expect(find.backButton(), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // expect(find.text('都市名を入力して下さい'), findsOneWidget);
    });

    testWidgets('text search', (tester) async {
      await tester.pumpWidget(createContainer());
      final container = tester.container();

      print(container.read(asyncWeatherProvider).error);
      print(
        container.read(asyncWeatherProvider).value?.currentWeatherData?.name,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      final textField = find.byType(TextField);

      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Paris');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Current Weather'), findsOneWidget);
    });
  });
}
