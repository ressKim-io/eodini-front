import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 사용자 역할
enum UserRole {
  @JsonValue('admin')
  admin, // 관리자
  @JsonValue('driver')
  driver, // 운전자
  @JsonValue('parent')
  parent, // 학부모
  @JsonValue('attendant')
  attendant, // 동승자
}

/// 사용자 모델
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// 로그인 요청 DTO
@freezed
class LoginDto with _$LoginDto {
  const factory LoginDto({
    required String email,
    required String password,
  }) = _LoginDto;

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);
}

/// 로그인 응답 DTO
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required User user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

/// 회원가입 요청 DTO
@freezed
class RegisterDto with _$RegisterDto {
  const factory RegisterDto({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
  }) = _RegisterDto;

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);
}

/// 토큰 갱신 요청 DTO
@freezed
class RefreshTokenDto with _$RefreshTokenDto {
  const factory RefreshTokenDto({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshTokenDto;

  factory RefreshTokenDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenDtoFromJson(json);
}

/// 토큰 갱신 응답 DTO
@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    @JsonKey(name: 'access_token') required String accessToken,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}
