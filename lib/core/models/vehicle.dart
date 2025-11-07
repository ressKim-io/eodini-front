import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// 차량 유형
enum VehicleType {
  @JsonValue('van')
  van, // 승합차
  @JsonValue('bus')
  bus, // 버스
  @JsonValue('mini_bus')
  miniBus, // 소형버스
  @JsonValue('sedan')
  sedan, // 승용차
}

/// 차량 상태
enum VehicleStatus {
  @JsonValue('active')
  active, // 운행 가능
  @JsonValue('maintenance')
  maintenance, // 정비 중
  @JsonValue('inactive')
  inactive, // 비활성 (폐차 등)
}

/// 차량 모델
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String id,
    @JsonKey(name: 'plate_number') required String plateNumber,
    required String model,
    required String manufacturer,
    @JsonKey(name: 'vehicle_type') required VehicleType vehicleType,
    required int capacity,
    required int year,
    required String color,
    required VehicleStatus status,
    @JsonKey(name: 'insurance_expiry') DateTime? insuranceExpiry,
    @JsonKey(name: 'inspection_expiry') DateTime? inspectionExpiry,
    @JsonKey(name: 'last_maintenance_at') DateTime? lastMaintenanceAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}

/// 차량 생성 DTO
@freezed
class CreateVehicleDto with _$CreateVehicleDto {
  const factory CreateVehicleDto({
    @JsonKey(name: 'plate_number') required String plateNumber,
    required String model,
    required String manufacturer,
    @JsonKey(name: 'vehicle_type') required VehicleType vehicleType,
    required int capacity,
    required int year,
    required String color,
  }) = _CreateVehicleDto;

  factory CreateVehicleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateVehicleDtoFromJson(json);
}

/// 차량 업데이트 DTO
@freezed
class UpdateVehicleDto with _$UpdateVehicleDto {
  const factory UpdateVehicleDto({
    String? model,
    String? manufacturer,
    @JsonKey(name: 'vehicle_type') VehicleType? vehicleType,
    int? capacity,
    int? year,
    String? color,
    VehicleStatus? status,
    @JsonKey(name: 'insurance_expiry') DateTime? insuranceExpiry,
    @JsonKey(name: 'inspection_expiry') DateTime? inspectionExpiry,
  }) = _UpdateVehicleDto;

  factory UpdateVehicleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateVehicleDtoFromJson(json);
}
