

import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/providers/async_weather.dart';
import 'package:open_weather/providers/shared_prefs_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'locale_provider.freezed.dart';
part 'locale_provider.g.dart';

@freezed
abstract class LocaleModel with _$LocaleModel {
  const factory LocaleModel ({
    required Locale locale,
}) = _LocaleModel;
}

@riverpod
class LocaleSetting extends _$LocaleSetting {

  @override
  LocaleModel build() {
    return LocaleModel(locale: _getLocale());
  }


  SharedPreferences? get prefs => ref.watch(sharedPrefsProvider).value;

  Locale _getLocale() {
    final locale = prefs?.getString('locale');
    return Locale(locale ?? 'en');
  }

  Future<void> setLocale(Locale newLocale) async {
    state = state.copyWith(locale: newLocale);
    await prefs?.setString('locale', state.locale?.languageCode ?? '');
    ref.invalidate(asyncWeatherProvider);
  }
}