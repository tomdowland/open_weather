import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_weather/models/enum/error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'error_provider.g.dart';

@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  RequestError? build(Object? exception) {
    switch (exception) {
      case DioException():
        if (exception.response?.statusCode == 404) {
          return RequestError.notFound;
        }
        if (exception.type == DioExceptionType.connectionTimeout ||
            exception.type == DioExceptionType.receiveTimeout) {
          return RequestError.requestTimeout;
        }
        return RequestError.networkError;
      case TimeoutException():
        return RequestError.requestTimeout;
      case LocationServiceDisabledException():
        return RequestError.locationServicesDisabled;
      case PermissionDeniedException():
        return RequestError.locationPermissionsDenied;
      case _:
        return RequestError.networkError;
    }
  }
}
