import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:open_weather/providers/locale_provider.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_provider_test.mocks.dart';

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

  group('locale tests', () {
    test('get locale, return en', () {
      final container = createContainer();

      when(
        container.read(sharedPrefsProvider).value?.getString('locale'),
      ).thenReturn('en');

      expect(container.read(localeSettingProvider).locale, const Locale('en'));
    });

    test('get locale, return jp', () {
      final container = createContainer();

      when(
        container.read(sharedPrefsProvider).value?.getString('locale'),
      ).thenReturn('jp');

      expect(container.read(localeSettingProvider).locale, const Locale('jp'));
    });

    test('change locale from init (en) to jp', () async {
      final container = createContainer();
      final notifier = container.read(localeSettingProvider.notifier);

      expect(container.read(localeSettingProvider).locale.languageCode, 'en');

      await notifier.setLocale(const Locale('jp'));

      expect(container.read(localeSettingProvider).locale.languageCode, 'jp');
    });
  });
}
