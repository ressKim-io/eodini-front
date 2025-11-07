import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';

/// 인증 Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

/// 인증 Repository
/// API 통신을 담당하는 레이어
class AuthRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AuthRepository(this._apiClient);

  /// 로그인
  Future<LoginResponse> login(LoginDto dto) async {
    try {
      _logger.d('🔐 로그인 시도: ${dto.email}');

      // Mock API 모드
      if (AppConstants.useMockApi) {
        _logger.d('🎭 Mock API 사용 중...');
        await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

        // Mock 사용자 데이터
        final mockUser = User(
          id: 'mock-user-id-123',
          email: dto.email,
          name: '테스트 사용자',
          phone: '010-1234-5678',
          role: UserRole.parent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final loginResponse = LoginResponse(
          accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
          user: mockUser,
        );

        _logger.d('✅ Mock 로그인 성공: ${loginResponse.user.name}');
        return loginResponse;
      }

      // 실제 API 호출
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        data: dto.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final loginResponse = LoginResponse.fromJson(apiResponse.data!);
      _logger.d('✅ 로그인 성공: ${loginResponse.user.name}');

      return loginResponse;
    } on DioException catch (e) {
      _logger.e('❌ 로그인 실패 (DioException)', error: e);
      if (e.response?.statusCode == 401) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
      throw Exception('로그인 중 오류가 발생했습니다.');
    } catch (e) {
      _logger.e('❌ 로그인 실패', error: e);
      rethrow;
    }
  }

  /// 회원가입
  Future<User> register(RegisterDto dto) async {
    try {
      _logger.d('📝 회원가입 시도: ${dto.email}');

      // Mock API 모드
      if (AppConstants.useMockApi) {
        _logger.d('🎭 Mock API 사용 중...');
        await Future.delayed(const Duration(seconds: 1));

        final mockUser = User(
          id: 'mock-user-id-${DateTime.now().millisecondsSinceEpoch}',
          email: dto.email,
          name: dto.name,
          phone: dto.phone,
          role: dto.role,
          address: dto.address,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _logger.d('✅ Mock 회원가입 성공: ${mockUser.name}');
        return mockUser;
      }

      // 실제 API 호출
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        data: dto.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final user = User.fromJson(apiResponse.data!);
      _logger.d('✅ 회원가입 성공: ${user.name}');

      return user;
    } on DioException catch (e) {
      _logger.e('❌ 회원가입 실패 (DioException)', error: e);
      if (e.response?.statusCode == 409) {
        throw Exception('이미 사용 중인 이메일입니다.');
      }
      throw Exception('회원가입 중 오류가 발생했습니다.');
    } catch (e) {
      _logger.e('❌ 회원가입 실패', error: e);
      rethrow;
    }
  }

  /// 내 정보 조회
  Future<User> getMe() async {
    try {
      _logger.d('👤 내 정보 조회');

      // Mock API 모드
      if (AppConstants.useMockApi) {
        _logger.d('🎭 Mock API 사용 중...');
        await Future.delayed(const Duration(milliseconds: 500));

        // 저장된 토큰이 있으면 mock 사용자 반환
        final mockUser = User(
          id: 'mock-user-id-123',
          email: 'test@example.com',
          name: '테스트 사용자',
          phone: '010-1234-5678',
          role: UserRole.parent,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        );

        _logger.d('✅ Mock 내 정보 조회 성공: ${mockUser.name}');
        return mockUser;
      }

      // 실제 API 호출
      final response = await _apiClient.get(ApiConstants.authMe);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final user = User.fromJson(apiResponse.data!);
      _logger.d('✅ 내 정보 조회 성공: ${user.name}');

      return user;
    } on DioException catch (e) {
      _logger.e('❌ 내 정보 조회 실패 (DioException)', error: e);
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }
      throw Exception('정보 조회 중 오류가 발생했습니다.');
    } catch (e) {
      _logger.e('❌ 내 정보 조회 실패', error: e);
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    try {
      _logger.d('🔄 토큰 갱신 시도');

      final response = await _apiClient.post(
        ApiConstants.authRefresh,
        data: RefreshTokenDto(refreshToken: refreshToken).toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      final refreshResponse = RefreshTokenResponse.fromJson(apiResponse.data!);
      _logger.d('✅ 토큰 갱신 성공');

      return refreshResponse;
    } on DioException catch (e) {
      _logger.e('❌ 토큰 갱신 실패 (DioException)', error: e);
      throw Exception('토큰 갱신에 실패했습니다.');
    } catch (e) {
      _logger.e('❌ 토큰 갱신 실패', error: e);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      _logger.d('👋 로그아웃 시도');

      await _apiClient.post(ApiConstants.authLogout);

      _logger.d('✅ 로그아웃 성공');
    } on DioException catch (e) {
      _logger.e('❌ 로그아웃 실패 (DioException)', error: e);
      // 로그아웃은 실패해도 로컬 토큰 삭제
    } catch (e) {
      _logger.e('❌ 로그아웃 실패', error: e);
    }
  }
}
