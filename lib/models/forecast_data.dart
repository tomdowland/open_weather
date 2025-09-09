import 'package:faker/faker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'forecast_data.freezed.dart';
part 'forecast_data.g.dart';

@freezed
abstract class ForecastData with _$ForecastData {
  const factory ForecastData({
    @JsonKey(name: 'cod') String? cod,
    @JsonKey(name: 'message') int? message,
    @JsonKey(name: 'cnt') int? cnt,
    @JsonKey(name: 'list') List<WeatherList>? weatherList,
    @JsonKey(name: 'city') City? city,
  }) = _ForecastData;

  factory ForecastData.fromJson(Map<String, dynamic> json) =>
      _$ForecastDataFromJson(json);

  factory ForecastData.dummy() {
    return ForecastData(
      city: City(
        name: faker.address.city(),
        timezone: DateTime.now().millisecondsSinceEpoch,
      ),
      weatherList: [
        ...List.generate(40, (length) {
          return WeatherList(
            dt: DateTime.now().millisecondsSinceEpoch,
            main: Main(
              temp: faker.randomGenerator.decimal(scale: 100, min: -100),
            ),
            weather: [
              Weather(
                main: faker.animal.name(),
                description: faker.animal.name(),
              ),
            ],
          );
        }),
      ],
    );
  }
}

@freezed
abstract class City with _$City {
  const factory City({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'coord') Coord? coord,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'population') int? population,
    @JsonKey(name: 'timezone') int? timezone,
    @JsonKey(name: 'sunrise') int? sunrise,
    @JsonKey(name: 'sunset') int? sunset,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}

@freezed
abstract class Coord with _$Coord {
  const factory Coord({
    @JsonKey(name: 'lat') double? lat,
    @JsonKey(name: 'lon') double? lon,
  }) = _Coord;

  factory Coord.fromJson(Map<String, dynamic> json) => _$CoordFromJson(json);
}

@freezed
abstract class WeatherList with _$WeatherList {
  const factory WeatherList({
    @JsonKey(name: 'dt') int? dt,
    @JsonKey(name: 'main') Main? main,
    @JsonKey(name: 'weather') List<Weather>? weather,
    @JsonKey(name: 'clouds') Clouds? clouds,
    @JsonKey(name: 'wind') Wind? wind,
    @JsonKey(name: 'visibility') int? visibility,
    @JsonKey(name: 'pop') double? pop,
    @JsonKey(name: 'rain') Rain? rain,
    @JsonKey(name: 'sys') Sys? sys,
    @JsonKey(name: 'dt_txt') String? dtTxt,
  }) = _WeeatherList;

  factory WeatherList.fromJson(Map<String, dynamic> json) =>
      _$WeatherListFromJson(json);
}

@freezed
abstract class Sys with _$Sys {
  const factory Sys({
    @JsonKey(name: 'pod') String? pod,
  }) = _Sys;

  factory Sys.fromJson(Map<String, dynamic> json) => _$SysFromJson(json);
}

@freezed
abstract class Rain with _$Rain {
  const factory Rain({
    @JsonKey(name: '3h') double? threeH,
  }) = _Rain;

  factory Rain.fromJson(Map<String, dynamic> json) => _$RainFromJson(json);
}

@freezed
abstract class Wind with _$Wind {
  const factory Wind({
    @JsonKey(name: 'speed') double? speed,
    @JsonKey(name: 'deg') int? deg,
    @JsonKey(name: 'gust') double? gust,
  }) = _Wind;

  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);
}

@freezed
abstract class Clouds with _$Clouds {
  const factory Clouds({
    @JsonKey(name: 'all') int? all,
  }) = _Clouds;

  factory Clouds.fromJson(Map<String, dynamic> json) => _$CloudsFromJson(json);
}

@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'main') String? main,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'icon') String? icon,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

@freezed
abstract class Main with _$Main {
  const factory Main({
    @JsonKey(name: 'temp') double? temp,
    @JsonKey(name: 'feels_like') double? feelsLike,
    @JsonKey(name: 'temp_min') double? tempMin,
    @JsonKey(name: 'temp_max') double? tempMax,
    @JsonKey(name: 'pressure') int? pressure,
    @JsonKey(name: 'sea_level') int? seaLevel,
    @JsonKey(name: 'grnd_level') int? grndLevel,
    @JsonKey(name: 'humidity') int? humidity,
    @JsonKey(name: 'temp_kf') double? tempKf,
  }) = _Main;

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
}
