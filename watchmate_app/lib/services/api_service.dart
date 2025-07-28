import 'package:watchmate_app/services/logger.dart';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  final int? statusCode;
  final T? body;

  ApiResponse({this.statusCode, this.body});
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        baseUrl: 'http://localhost:5000',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final tag = "[${response.requestOptions.method}] RESPONSE";
          Logger.success(
            message: "${response.statusCode} ${response.requestOptions.uri}",
            tag: tag,
          );

          Logger.success(tag: tag, message: response.data);
          return handler.next(response);
        },
        onRequest: (options, handler) {
          final tag = "${options.method} REQUEST";
          Logger.info(tag: tag, message: options.uri);
          Logger.info(tag: tag, message: options.headers);
          Logger.info(tag: tag, message: options.data);
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final req = e.requestOptions;
          final tag = "[${req.method}] ERROR";
          Logger.error(
            message: "${e.response?.statusCode} ${req.uri}",
            tag: tag,
          );

          Logger.error(tag: tag, message: e.message);
          if (e.response != null) {
            Logger.error(tag: tag, message: e.response?.data);
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setBaseUrl(String baseUrl) => _dio.options.baseUrl = baseUrl;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(
        path,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return ApiResponse<T>(statusCode: res.statusCode, body: res.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return ApiResponse<T>(statusCode: res.statusCode, body: res.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data', ...?headers},
        ),
      );
      return ApiResponse<T>(statusCode: res.statusCode, body: res.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleError<T>(Object e) {
    if (e is DioException) {
      final res = e.response;
      final dynamic errorBody = res?.data is Map && res?.data['message'] != null
          ? res?.data['message']
          : res?.data ?? e.message;
      return ApiResponse<T>(statusCode: res?.statusCode, body: errorBody);
    }

    return ApiResponse<T>(
      body: ('Unexpected error occurred: ${e.toString()}') as T?,
      statusCode: 500,
    );
  }
}
