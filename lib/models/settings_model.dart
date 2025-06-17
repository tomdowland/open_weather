import 'package:freezed_annotation/freezed_annotation.dart';
part 'settings_model.freezed.dart';

@freezed
abstract class Settings with _$Settings {
  factory Settings({String? locale, bool? lightMode, String? units}) =
      _Settings;
}
