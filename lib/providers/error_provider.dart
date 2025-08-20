import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'error_provider.g.dart';

@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  RequestError? build(Exception? exception) {
    switch (exception) {
      case DioException():
        if (exception.response?.statusCode == 404) {
          return RequestError.notFound;
        } else {
          return RequestError.networkError;
        }
      case TimeoutException():
        return RequestError.requestTimeout;
      case LocationServiceDisabledException():
        return RequestError.locationServicesDisabled;
      case _:
        return null;
    }
  }
}
