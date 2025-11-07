import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// 일정 상태
enum ScheduleStatus {
  @JsonValue('active')
  active, // 사용 중
  @JsonValue('inactive')
  inactive, // 미사용
}

/// 시간대
enum TimeSlot {
  @JsonValue('morning')
  morning, // 오전
  @JsonValue('afternoon')
  afternoon, // 오후
  @JsonValue('evening')
  evening, // 저녁
}

/// 일정 모델
@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    required String name,
    required String description,
    required ScheduleStatus status,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'time_slot') required TimeSlot timeSlot,
    @JsonKey(name: 'days_of_week') required List<int> daysOfWeek,
    @JsonKey(name: 'route_id') required String routeId,
    @JsonKey(name: 'vehicle_id') required String vehicleId,
    @JsonKey(name: 'default_driver_id') required String defaultDriverId,
    @JsonKey(name: 'default_attendant_id') String? defaultAttendantId,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_to') DateTime? validTo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}

/// 일정 생성 DTO
@freezed
class CreateScheduleDto with _$CreateScheduleDto {
  const factory CreateScheduleDto({
    required String name,
    required String description,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'time_slot') required TimeSlot timeSlot,
    @JsonKey(name: 'days_of_week') required List<int> daysOfWeek,
    @JsonKey(name: 'route_id') required String routeId,
    @JsonKey(name: 'vehicle_id') required String vehicleId,
    @JsonKey(name: 'default_driver_id') required String defaultDriverId,
    @JsonKey(name: 'default_attendant_id') String? defaultAttendantId,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_to') DateTime? validTo,
  }) = _CreateScheduleDto;

  factory CreateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleDtoFromJson(json);
}

/// 일정 업데이트 DTO
@freezed
class UpdateScheduleDto with _$UpdateScheduleDto {
  const factory UpdateScheduleDto({
    String? name,
    String? description,
    ScheduleStatus? status,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'time_slot') TimeSlot? timeSlot,
    @JsonKey(name: 'days_of_week') List<int>? daysOfWeek,
    @JsonKey(name: 'vehicle_id') String? vehicleId,
    @JsonKey(name: 'default_driver_id') String? defaultDriverId,
    @JsonKey(name: 'default_attendant_id') String? defaultAttendantId,
    @JsonKey(name: 'valid_from') DateTime? validFrom,
    @JsonKey(name: 'valid_to') DateTime? validTo,
  }) = _UpdateScheduleDto;

  factory UpdateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateScheduleDtoFromJson(json);
}
