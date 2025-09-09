import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
import 'package:open_weather/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() async {
  ProviderContainer createContainer() {
    final container = ProviderContainer.test(
      overrides: [
        sharedPrefsProvider.overrideWith((ref) {
          return MockSharedPreferences();
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('theme provider tests', () {
    test('get theme return light', () {
      final container = createContainer();

      when(
        container.read(sharedPrefsProvider).value?.getBool('dark_mode'),
      ).thenReturn(false);

      expect(container.read(themeSettingProvider).darkMode, false);
    });

    test('get theme return dark', () {
      final container = createContainer();

      when(
        container.read(sharedPrefsProvider).value?.getBool('dark_mode'),
      ).thenReturn(true);

      expect(container.read(themeSettingProvider).darkMode, true);
    });

    test('change form init (light) to dark mode', () async {
      final container = createContainer();
      final notifier = container.read(themeSettingProvider.notifier);

      expect(container.read(themeSettingProvider).darkMode, false);

      await notifier.toggleDarkMode();

      expect(container.read(themeSettingProvider).darkMode, true);
    });
  });
}
