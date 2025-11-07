import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../../../core/models/user.dart';
import '../../../core/services/auth_repository.dart';
import '../../../core/services/token_storage_service.dart';

part 'auth_provider.freezed.dart';

/// 인증 상태
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? errorMessage,
  }) = _AuthState;
}

/// 인증 상태 Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return AuthNotifier(authRepository, tokenStorage);
});

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorageService _tokenStorage;
  final Logger _logger = Logger();

  AuthNotifier(this._authRepository, this._tokenStorage)
      : super(const AuthState()) {
    // 초기화: 저장된 토큰으로 자동 로그인 시도
    _initAuth();
  }

  /// 초기화: 자동 로그인
  Future<void> _initAuth() async {
    try {
      final isLoggedIn = await _tokenStorage.isLoggedIn();
      if (isLoggedIn) {
        _logger.d('🔄 자동 로그인 시도');
        final user = await _authRepository.getMe();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
        _logger.d('✅ 자동 로그인 성공: ${user.name}');
      }
    } catch (e) {
      _logger.w('⚠️  자동 로그인 실패: $e');
      // 토큰이 만료되었을 수 있으므로 삭제
      await _tokenStorage.clearAll();
    }
  }

  /// 로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loginDto = LoginDto(email: email, password: password);
      final loginResponse = await _authRepository.login(loginDto);

      // 토큰 및 사용자 정보 저장
      await _tokenStorage.saveAuthData(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        userId: loginResponse.user.id,
        userRole: loginResponse.user.role.name,
      );

      state = state.copyWith(
        user: loginResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );

      _logger.d('✅ 로그인 완료: ${loginResponse.user.name}');
    } catch (e) {
      _logger.e('❌ 로그인 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// 회원가입
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final registerDto = RegisterDto(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        address: address,
      );

      await _authRepository.register(registerDto);

      state = state.copyWith(isLoading: false);

      _logger.d('✅ 회원가입 완료');

      // 회원가입 후 자동 로그인
      await login(email: email, password: password);
    } catch (e) {
      _logger.e('❌ 회원가입 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 서버에 로그아웃 요청
      await _authRepository.logout();

      // 로컬 토큰 삭제
      await _tokenStorage.clearAll();

      state = const AuthState();

      _logger.d('✅ 로그아웃 완료');
    } catch (e) {
      _logger.e('❌ 로그아웃 실패: $e');
      // 에러가 발생해도 로컬 상태는 초기화
      await _tokenStorage.clearAll();
      state = const AuthState();
    }
  }

  /// 사용자 정보 갱신
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getMe();
      state = state.copyWith(user: user);
      _logger.d('✅ 사용자 정보 갱신 완료');
    } catch (e) {
      _logger.e('❌ 사용자 정보 갱신 실패: $e');
      rethrow;
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
