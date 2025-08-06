import 'package:watchmate_app/utils/network_utils.dart';
import 'package:watchmate_app/utils/logger.dart';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  final int? statusCode;
  final String? error;
  final T? body;

  ApiResponse({this.statusCode, this.body, this.error});

  @override
  String toString() {
    return "ApiResponse(statusCode: $statusCode, error: $error, body: $body)";
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        baseUrl: NetworkUtils.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final tag = "${options.method} REQUEST";
          Logger.info(
            tag: tag,
            message: {
              "uri": options.uri.toString(),
              "params": options.queryParameters,
              "headers": options.headers,
              "body": options.data,
            },
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final tag = "${response.requestOptions.method} RESPONSE";
          Logger.success(
            tag: tag,
            message: {
              "uri": response.requestOptions.uri.toString(),
              "statusCode": response.statusCode,
              "body": response.data,
            },
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final req = e.requestOptions;
          final tag = "${req.method} ERROR";

          Logger.error(
            tag: tag,
            message: {
              "uri": req.uri.toString(),
              "statusCode": e.response?.statusCode,
              "error": e.response?.data,
              "message": e.message,
            },
          );
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
      final message = switch (e.type) {
        DioExceptionType.unknown => "Network error, please try again later",
        DioExceptionType.badCertificate => "Service unavailable (bad cert)",
        DioExceptionType.connectionError => "Couldn't connect to server",
        DioExceptionType.badResponse => _extractServerError(e.response),
        DioExceptionType.connectionTimeout => "Connection timeout",
        DioExceptionType.receiveTimeout => "Server response timeout",
        DioExceptionType.sendTimeout => "Client send timeout",
        DioExceptionType.cancel => "Request was cancelled",
      };

      return _prepareError(message);
    }
    return _prepareError(e.toString());
  }

  String _extractServerError(Response? response) {
    if (response?.statusCode == 404) {
      return "404 - Route Not Found";
    }

    final data = response?.data;
    if (data == null) return "Unexpected server error";

    if (data is String) return data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    return "Unknown error occurred";
  }

  ApiResponse<T> _prepareError<T>(String error, {int statusCode = 500}) {
    return ApiResponse<T>(statusCode: statusCode, error: error);
  }
}
