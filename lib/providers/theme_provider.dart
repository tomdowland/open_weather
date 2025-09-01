import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'theme_provider.freezed.dart';
part 'theme_provider.g.dart';

@freezed
abstract class ThemeModel with _$ThemeModel {
  const factory ThemeModel({
    required bool darkMode,
  }) = _ThemeModel;
}

@riverpod
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeModel build() {
    return ThemeModel(darkMode: _getDarkModeSetting());
  }

  SharedPreferences? get prefs => ref.watch(sharedPrefsProvider).value;

  bool _getDarkModeSetting() {
    return prefs?.getBool('dark_mode') ?? false;
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    await prefs?.setBool('dark_mode', state.darkMode);
  }
}
