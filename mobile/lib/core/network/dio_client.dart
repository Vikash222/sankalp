import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'api_response_model.dart';

class DioClient {
  late final Dio dio;
  final TokenStorage tokenStorage;

  DioClient({required this.tokenStorage}) {
    const String envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: ApiEndpoints.defaultBaseUrl,
    );

    dio = Dio(
      BaseOptions(
        baseUrl: envUrl,
        // Fast 4-second timeouts for responsive failover to offline cache
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        sendTimeout: const Duration(seconds: 4),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('--> ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint('<-- ERROR [${e.response?.statusCode}] ${e.requestOptions.uri}');
            debugPrint('Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Helper GET method
  Future<ApiResponseModel<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return ApiResponseModel.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponseModel<T>(
        success: false,
        error: ApiErrorModel(code: 'CLIENT_ERROR', message: e.toString()),
      );
    }
  }

  /// Helper POST method
  Future<ApiResponseModel<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return ApiResponseModel.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponseModel<T>(
        success: false,
        error: ApiErrorModel(code: 'CLIENT_ERROR', message: e.toString()),
      );
    }
  }

  /// Helper PUT method
  Future<ApiResponseModel<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.put(path, data: data, queryParameters: queryParameters);
      return ApiResponseModel.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponseModel<T>(
        success: false,
        error: ApiErrorModel(code: 'CLIENT_ERROR', message: e.toString()),
      );
    }
  }

  /// Helper DELETE method
  Future<ApiResponseModel<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await dio.delete(path, data: data, queryParameters: queryParameters);
      return ApiResponseModel.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponseModel<T>(
        success: false,
        error: ApiErrorModel(code: 'CLIENT_ERROR', message: e.toString()),
      );
    }
  }

  ApiResponseModel<T> _handleDioError<T>(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return ApiResponseModel<T>.fromJson(data, null);
      }
    }

    String message = 'Network connection failed. Please check your connection.';
    String code = 'NETWORK_ERROR';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Request timed out. Please try again.';
      code = 'TIMEOUT';
    } else if (e.response?.statusCode == 401) {
      message = 'Session expired. Please log in again.';
      code = 'UNAUTHENTICATED';
    }

    return ApiResponseModel<T>(
      success: false,
      error: ApiErrorModel(code: code, message: message),
    );
  }
}
