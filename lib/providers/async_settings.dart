import 'dart:ui';

import 'package:open_weather/providers/settings_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'async_settings.g.dart';

@riverpod
class AsyncSettings extends _$AsyncSettings {
  @override
  Future<SettingsModel> build() async {
    final darkMode = await _getDarkModeSetting();
    final locale = await getLocale();
    return SettingsModel(darkMode: darkMode, locale: locale);
  }

  Future<bool> _getDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') == true;
  }

  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale');
    return Locale(locale ?? 'en');
  }
}
