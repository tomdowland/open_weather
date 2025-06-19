import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/providers/async_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

@freezed
abstract class SettingsModel with _$SettingsModel {
  factory SettingsModel({
    Locale? locale,
    @Default(false) bool darkMode,
    String? units,
  }) = _SettingsModel;
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsModel build() {
    final asyncSettings = ref.watch(asyncSettingsProvider);
    return SettingsModel(darkMode: asyncSettings.value?.darkMode ?? false);
  }

  void toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', state.darkMode);
  }

  void setLocale(Locale newLocale) async {
    state = state.copyWith(locale: newLocale);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', state.locale?.languageCode ?? '');
  }
}
