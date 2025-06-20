import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/weather_model.dart';
part 'full_result_model.freezed.dart';
part 'full_result_model.g.dart';

@freezed
abstract class FullResult with _$FullResult {
  factory FullResult({
    String? city,
    String? country,
    String? weather,
    double? temperature,
    int? dateTime,
    String? icon,
    List<WeatherModel>? forecast,
  }) = _FullResult;

  factory FullResult.fromJson(Map<String, dynamic> json) =>
      _$FullResultFromJson(json);
}
