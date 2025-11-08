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
  @JsonValue('passenger')
  passenger, // 일반 탑승자 (성인 본인)
}

/// 사용자 타입 (회원가입 시 선택)
enum UserType {
  @JsonValue('parent')
  parent, // 보호자 (자녀 정보 입력)
  @JsonValue('passenger')
  passenger, // 일반 회원 (본인 정보만)
  @JsonValue('driver')
  driver, // 운전자
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
    // 공개/비공개 설정
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    // 탑승자 연결 (parent, passenger 역할인 경우)
    @JsonKey(name: 'passenger_id') String? passengerId,
    // 운전자 연결 (driver 역할인 경우)
    @JsonKey(name: 'driver_id') String? driverId,
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
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
  }) = _RegisterDto;

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);
}

/// 보호자 회원가입 요청 DTO (아동 정보 포함)
@freezed
class ParentRegisterDto with _$ParentRegisterDto {
  const factory ParentRegisterDto({
    // 보호자 본인 정보
    required String email,
    required String password,
    @JsonKey(name: 'guardian_name') required String guardianName,
    @JsonKey(name: 'guardian_phone') required String guardianPhone,
    @JsonKey(name: 'guardian_address') String? guardianAddress,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    // 아동 정보
    @JsonKey(name: 'child_name') required String childName,
    @JsonKey(name: 'child_birth_year') required int childBirthYear,
    @JsonKey(name: 'child_gender') String? childGender,
    @JsonKey(name: 'guardian_relation') @Default('부모') String guardianRelation,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'emergency_relation') String? emergencyRelation,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
  }) = _ParentRegisterDto;

  factory ParentRegisterDto.fromJson(Map<String, dynamic> json) =>
      _$ParentRegisterDtoFromJson(json);
}

/// 일반 회원(성인 탑승자) 회원가입 요청 DTO
@freezed
class PassengerRegisterDto with _$PassengerRegisterDto {
  const factory PassengerRegisterDto({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? address,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'birth_year') int? birthYear,
    String? gender,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'emergency_relation') String? emergencyRelation,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
  }) = _PassengerRegisterDto;

  factory PassengerRegisterDto.fromJson(Map<String, dynamic> json) =>
      _$PassengerRegisterDtoFromJson(json);
}

/// 운전자 회원가입 요청 DTO
@freezed
class DriverRegisterDto with _$DriverRegisterDto {
  const factory DriverRegisterDto({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? address,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    // 면허 정보
    @JsonKey(name: 'license_number') required String licenseNumber,
    @JsonKey(name: 'license_type') required String licenseType,
    @JsonKey(name: 'license_expiry') required String licenseExpiry,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
  }) = _DriverRegisterDto;

  factory DriverRegisterDto.fromJson(Map<String, dynamic> json) =>
      _$DriverRegisterDtoFromJson(json);
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
