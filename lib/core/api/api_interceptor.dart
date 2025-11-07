import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

/// 인증 인터셉터
/// JWT 토큰을 자동으로 헤더에 추가
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰이 필요한 엔드포인트인지 확인
    if (_needsAuth(options.path)) {
      final token = await _storage.read(key: AppConstants.keyAccessToken);
      if (token != null) {
        options.headers[ApiConstants.authorization] =
            ApiConstants.bearerToken(token);
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 (인증 실패) 처리
    if (err.response?.statusCode == 401) {
      _logger.w('Unauthorized: Token expired or invalid');

      // 토큰 갱신 시도
      final refreshed = await _refreshToken();
      if (refreshed) {
        // 원래 요청 재시도
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          _logger.e('Retry failed after token refresh', error: e);
        }
      }

      // 토큰 갱신 실패 시 로그아웃 처리
      await _clearTokens();
    }

    handler.next(err);
  }

  /// 인증이 필요한 엔드포인트인지 확인
  bool _needsAuth(String path) {
    final publicPaths = [
      ApiConstants.authLogin,
      ApiConstants.authRegister,
      ApiConstants.health,
      ApiConstants.healthReady,
      ApiConstants.healthLive,
    ];

    return !publicPaths.any((p) => path.contains(p));
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken == null) return false;

      final dio = Dio(); // 새로운 Dio 인스턴스 (인터셉터 없이)
      final response = await dio.post(
        '${ApiConstants.authRefresh}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['access_token'];
        await _storage.write(
          key: AppConstants.keyAccessToken,
          value: newAccessToken,
        );
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      return false;
    }
  }

  /// 요청 재시도
  Future<Response> _retry(RequestOptions requestOptions) async {
    final dio = Dio();
    final token = await _storage.read(key: AppConstants.keyAccessToken);

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        ApiConstants.authorization: ApiConstants.bearerToken(token!),
      },
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyUserRole);
  }
}

/// 로깅 인터셉터
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
🌐 REQUEST
${options.method} ${options.uri}
Headers: ${options.headers}
Data: ${options.data}
''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('''
✅ RESPONSE
${response.statusCode} ${response.requestOptions.uri}
Data: ${response.data}
''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
❌ ERROR
${err.response?.statusCode} ${err.requestOptions.uri}
Message: ${err.message}
Response: ${err.response?.data}
''');
    handler.next(err);
  }
}
