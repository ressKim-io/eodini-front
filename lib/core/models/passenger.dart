import 'package:freezed_annotation/freezed_annotation.dart';

part 'passenger.freezed.dart';
part 'passenger.g.dart';

/// 탑승자 상태
enum PassengerStatus {
  @JsonValue('active')
  active, // 활동 중
  @JsonValue('inactive')
  inactive, // 비활성 (졸업, 전학 등)
}

/// 탑승자 모델
@freezed
class Passenger with _$Passenger {
  const factory Passenger({
    required String id,
    required String name,
    int? age,
    String? gender,
    required PassengerStatus status,
    @JsonKey(name: 'assigned_route_id') required String assignedRouteId,
    @JsonKey(name: 'assigned_stop_id') required String assignedStopId,
    @JsonKey(name: 'stop_order') required int stopOrder,
    @JsonKey(name: 'guardian_name') required String guardianName,
    @JsonKey(name: 'guardian_phone') required String guardianPhone,
    @JsonKey(name: 'guardian_email') String? guardianEmail,
    @JsonKey(name: 'guardian_relation') String? guardianRelation,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'emergency_relation') String? emergencyRelation,
    String? address,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Passenger;

  factory Passenger.fromJson(Map<String, dynamic> json) =>
      _$PassengerFromJson(json);
}

/// 탑승자 생성 DTO
@freezed
class CreatePassengerDto with _$CreatePassengerDto {
  const factory CreatePassengerDto({
    required String name,
    int? age,
    String? gender,
    @JsonKey(name: 'guardian_name') required String guardianName,
    @JsonKey(name: 'guardian_phone') required String guardianPhone,
    @JsonKey(name: 'guardian_email') String? guardianEmail,
    @JsonKey(name: 'guardian_relation') String? guardianRelation,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'emergency_relation') String? emergencyRelation,
    String? address,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
    String? notes,
  }) = _CreatePassengerDto;

  factory CreatePassengerDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePassengerDtoFromJson(json);
}

/// 탑승자 업데이트 DTO
@freezed
class UpdatePassengerDto with _$UpdatePassengerDto {
  const factory UpdatePassengerDto({
    String? name,
    int? age,
    String? gender,
    PassengerStatus? status,
    @JsonKey(name: 'guardian_name') String? guardianName,
    @JsonKey(name: 'guardian_phone') String? guardianPhone,
    @JsonKey(name: 'guardian_email') String? guardianEmail,
    @JsonKey(name: 'guardian_relation') String? guardianRelation,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'emergency_relation') String? emergencyRelation,
    String? address,
    @JsonKey(name: 'medical_notes') String? medicalNotes,
    String? notes,
  }) = _UpdatePassengerDto;

  factory UpdatePassengerDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePassengerDtoFromJson(json);
}
