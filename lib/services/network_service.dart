import 'package:dio/dio.dart';

const String _url = 'https://api.openweathermap.org/';
const String _apiKey = 'e5d3ccda6cdaa06e3c5c154dc9fc6c94';

class DioClient {
  late final Dio _dio;
  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _url,
          queryParameters: {'api_key': _apiKey},
          responseType: ResponseType.json,
        ),
      );

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}

class NetworkCalls {}
