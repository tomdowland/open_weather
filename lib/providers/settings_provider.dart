import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

@freezed
abstract class SettingsModel with _$SettingsModel {
  factory SettingsModel({
    String? locale,
    @Default(false) bool darkMode,
    String? units,
  }) = _SettingsModel;
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsModel build() {
    return SettingsModel();
  }

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
  }
}
