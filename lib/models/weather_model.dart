import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

@freezed
abstract class WeatherModel with _$WeatherModel {
  factory WeatherModel({
    @Default('') String city,
    @Default('') String country,
    @Default('') String weather,
    @Default(0) double temperature,
    @Default(0) int dateTime,
    String? icon,
  }) = _WeatherModel;

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);
}
