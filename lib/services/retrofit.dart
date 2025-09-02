import 'package:dio/dio.dart';
import 'package:open_weather/models/current_weather.dart';
import 'package:open_weather/models/forecast_data.dart';
import 'package:retrofit/retrofit.dart';

part 'retrofit.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET('/forecast')
  Future<ForecastData> weatherSearch({
    // @Query('appid') required String apiKey,
    @Query('units') required String units,
    @Query('lang') required String language,
    @Query('q') String? city,
    @Query('lat') double? lat,
    @Query('lon') double? lon,
  });

  @GET('/weather')
  Future<CurrentWeather> currentWeatherSearch({
    // @Query('appid') required String apiKey,
    @Query('units') required String units,
    @Query('lang') required String language,
    @Query('q') String? city,
    @Query('lat') double? lat,
    @Query('lon') double? lon,
  });
}
