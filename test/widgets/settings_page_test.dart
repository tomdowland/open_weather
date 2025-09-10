import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:open_weather/l10n/app_localizations.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
import 'package:open_weather/ui/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SharedPreferences>(),
])
void main() async {
  MaterialApp createTestContainer() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ja')],
      home: ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWith(
            (ref) => MockSharedPreferences(),
          ),
        ],
        child: const SettingsPage(),
      ),
    );
  }

  group('settings page', () {
    testWidgets('initial layout', (tester) async {
      await tester.pumpWidget(
        createTestContainer(),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Locale>), findsOneWidget);

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(
        tester
            .widget<DropdownButtonFormField<Locale>>(
              find.byType(DropdownButtonFormField<Locale>),
            )
            .initialValue,
        const Locale('en'),
      );
    });

    testWidgets('set theme', (tester) async {
      await tester.pumpWidget(
        createTestContainer(),
      );
      final themeSwitch = find.byType(Switch);

      expect(tester.widget<Switch>(themeSwitch).value, isFalse);

      await tester.tap(themeSwitch);
      await tester.pump();

      expect(tester.widget<Switch>(themeSwitch).value, isTrue);

      await tester.tap(themeSwitch);
      await tester.pump();

      expect(tester.widget<Switch>(themeSwitch).value, isFalse);
    });

    testWidgets('set locale', (tester) async {
      await tester.pumpWidget(
        createTestContainer(),
      );
      final localeDropdown = find.byType(DropdownButtonFormField<Locale>);

      expect(find.text('English'), findsOneWidget);
      expect(find.text('日本語'), findsNothing);

      await tester.tap(localeDropdown);
      await tester.pump();
      await tester.tap(find.text('日本語'));
      await tester.pump();

      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('English'), findsNothing);

      await tester.tap(localeDropdown);
      await tester.pump();
      await tester.tap(find.text('English'));
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('日本語'), findsNothing);
    });
  });
}
