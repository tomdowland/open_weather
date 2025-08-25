import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
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
    return SettingsModel(
      darkMode: _getDarkModeSetting(),
      locale: _getLocale(),
    );
  }

  SharedPreferences? get prefs => ref.watch(sharedPrefsProvider).value;

  Locale _getLocale() {
    final locale = prefs?.getString('locale');
    return Locale(locale ?? 'en');
  }

  bool _getDarkModeSetting() {
    return prefs?.getBool('dark_mode') ?? false;
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    await prefs?.setBool('dark_mode', state.darkMode);
  }

  Future<void> setLocale(Locale newLocale) async {
    state = state.copyWith(locale: newLocale);
    await prefs?.setString('locale', state.locale?.languageCode ?? '');
    ref.invalidate(asyncWeatherProvider);
  }
}
