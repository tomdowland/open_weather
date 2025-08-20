

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';

part 'weather_result.freezed.dart';

@freezed
abstract class WeatherResult with _$WeatherResult{
  const factory WeatherResult({
    CurrentWeather?  currentWeatherData,
    ForecastData? forecastData,
}) = _WeatherResult;
}
