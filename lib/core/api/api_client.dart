import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import 'api_interceptor.dart';

/// Dio 클라이언트 Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions);

  // 인터셉터 추가
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LoggingInterceptor());

  return dio;
});

/// Dio 기본 옵션
BaseOptions get _baseOptions {
  // dotenv가 초기화되지 않았을 경우 기본값 사용
  String baseUrl = 'http://localhost:8080/api/v1';
  try {
    if (dotenv.isInitialized) {
      baseUrl = dotenv.env['API_BASE_URL'] ?? baseUrl;
    }
  } catch (e) {
    // dotenv 접근 실패 시 기본값 사용
  }

  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
    headers: {
      ApiConstants.contentType: ApiConstants.applicationJson,
    },
  );
}

/// API 클라이언트 클래스
class ApiClient {
  final Dio _dio;
  final Logger _logger = Logger();

  ApiClient(this._dio);

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _logger.e('GET Error: ${e.message}', error: e);
      rethrow;
    }
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _logger.e('POST Error: ${e.message}', error: e);
      rethrow;
    }
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _logger.e('PUT Error: ${e.message}', error: e);
      rethrow;
    }
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _logger.e('DELETE Error: ${e.message}', error: e);
      rethrow;
    }
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _logger.e('PATCH Error: ${e.message}', error: e);
      rethrow;
    }
  }
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
