import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver.freezed.dart';
part 'driver.g.dart';

/// 기사 상태
enum DriverStatus {
  @JsonValue('active')
  active, // 활동 중
  @JsonValue('on_leave')
  onLeave, // 휴가 중
  @JsonValue('inactive')
  inactive, // 비활성 (퇴사 등)
}

/// 운전면허 종류
enum LicenseType {
  @JsonValue('type_1_regular')
  type1Regular, // 1종 보통
  @JsonValue('type_1_large')
  type1Large, // 1종 대형
  @JsonValue('type_2_regular')
  type2Regular, // 2종 보통
}

/// 기사 모델
@freezed
class Driver with _$Driver {
  const factory Driver({
    required String id,
    required String name,
    required String phone,
    String? email,
    required DriverStatus status,
    @JsonKey(name: 'license_number') required String licenseNumber,
    @JsonKey(name: 'license_type') required LicenseType licenseType,
    @JsonKey(name: 'license_expiry') required DateTime licenseExpiry,
    @JsonKey(name: 'hire_date') required DateTime hireDate,
    @JsonKey(name: 'termination_date') DateTime? terminationDate,
    String? address,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Driver;

  factory Driver.fromJson(Map<String, dynamic> json) =>
      _$DriverFromJson(json);
}

/// 기사 생성 DTO
@freezed
class CreateDriverDto with _$CreateDriverDto {
  const factory CreateDriverDto({
    required String name,
    required String phone,
    String? email,
    @JsonKey(name: 'license_number') required String licenseNumber,
    @JsonKey(name: 'license_type') required LicenseType licenseType,
    @JsonKey(name: 'license_expiry') required DateTime licenseExpiry,
    String? address,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    String? notes,
  }) = _CreateDriverDto;

  factory CreateDriverDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDriverDtoFromJson(json);
}

/// 기사 업데이트 DTO
@freezed
class UpdateDriverDto with _$UpdateDriverDto {
  const factory UpdateDriverDto({
    String? name,
    String? phone,
    String? email,
    DriverStatus? status,
    @JsonKey(name: 'license_expiry') DateTime? licenseExpiry,
    String? address,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    String? notes,
  }) = _UpdateDriverDto;

  factory UpdateDriverDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDriverDtoFromJson(json);
}
