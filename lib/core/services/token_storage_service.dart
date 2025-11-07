import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// 토큰 저장소 서비스 Provider
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// 토큰 저장소 서비스
/// JWT 토큰을 안전하게 저장/조회/삭제
class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: AppConstants.keyAccessToken, value: token);
      _logger.d('✅ Access Token 저장 완료');
    } catch (e) {
      _logger.e('❌ Access Token 저장 실패', error: e);
      rethrow;
    }
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.keyAccessToken);
    } catch (e) {
      _logger.e('❌ Access Token 조회 실패', error: e);
      return null;
    }
  }

  /// Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.keyRefreshToken, value: token);
      _logger.d('✅ Refresh Token 저장 완료');
    } catch (e) {
      _logger.e('❌ Refresh Token 저장 실패', error: e);
      rethrow;
    }
  }

  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.keyRefreshToken);
    } catch (e) {
      _logger.e('❌ Refresh Token 조회 실패', error: e);
      return null;
    }
  }

  /// 사용자 ID 저장
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: AppConstants.keyUserId, value: userId);
      _logger.d('✅ User ID 저장 완료');
    } catch (e) {
      _logger.e('❌ User ID 저장 실패', error: e);
      rethrow;
    }
  }

  /// 사용자 ID 조회
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: AppConstants.keyUserId);
    } catch (e) {
      _logger.e('❌ User ID 조회 실패', error: e);
      return null;
    }
  }

  /// 사용자 역할 저장
  Future<void> saveUserRole(String role) async {
    try {
      await _storage.write(key: AppConstants.keyUserRole, value: role);
      _logger.d('✅ User Role 저장 완료: $role');
    } catch (e) {
      _logger.e('❌ User Role 저장 실패', error: e);
      rethrow;
    }
  }

  /// 사용자 역할 조회
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: AppConstants.keyUserRole);
    } catch (e) {
      _logger.e('❌ User Role 조회 실패', error: e);
      return null;
    }
  }

  /// 모든 토큰 및 사용자 정보 삭제 (로그아웃)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: AppConstants.keyAccessToken),
        _storage.delete(key: AppConstants.keyRefreshToken),
        _storage.delete(key: AppConstants.keyUserId),
        _storage.delete(key: AppConstants.keyUserRole),
      ]);
      _logger.d('✅ 모든 인증 정보 삭제 완료');
    } catch (e) {
      _logger.e('❌ 인증 정보 삭제 실패', error: e);
      rethrow;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// 모든 인증 정보 한번에 저장
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userRole,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserRole(userRole),
    ]);
    _logger.d('✅ 모든 인증 정보 저장 완료');
  }
}
