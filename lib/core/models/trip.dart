import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

/// 운행 상태
enum TripStatus {
  @JsonValue('pending')
  pending, // 대기 중
  @JsonValue('in_progress')
  inProgress, // 운행 중
  @JsonValue('completed')
  completed, // 완료
  @JsonValue('cancelled')
  cancelled, // 취소
}

/// 위치 정보
@freezed
class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

/// 운행 모델
@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    required DateTime date,
    required TripStatus status,
    @JsonKey(name: 'vehicle_id') required String vehicleId,
    @JsonKey(name: 'assigned_driver_id') required String assignedDriverId,
    @JsonKey(name: 'assigned_attendant_id') String? assignedAttendantId,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'started_by') String? startedBy,
    @JsonKey(name: 'actual_start_location') Location? actualStartLocation,
    @JsonKey(name: 'actual_end_location') Location? actualEndLocation,
    @JsonKey(name: 'total_distance') int? totalDistance,
    @JsonKey(name: 'trip_passengers') List<TripPassenger>? tripPassengers,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

/// 탑승자별 운행 기록
@freezed
class TripPassenger with _$TripPassenger {
  const factory TripPassenger({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    @JsonKey(name: 'passenger_id') required String passengerId,
    @JsonKey(name: 'stop_id') required String stopId,
    @JsonKey(name: 'boarded_at') DateTime? boardedAt,
    @JsonKey(name: 'alighted_at') DateTime? alightedAt,
    @JsonKey(name: 'is_boarded') required bool isBoarded,
    @JsonKey(name: 'is_alighted') required bool isAlighted,
    @JsonKey(name: 'no_show_reason') String? noShowReason,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TripPassenger;

  factory TripPassenger.fromJson(Map<String, dynamic> json) =>
      _$TripPassengerFromJson(json);
}

/// 운행 시작 DTO
@freezed
class StartTripDto with _$StartTripDto {
  const factory StartTripDto({
    @JsonKey(name: 'started_by') required String startedBy,
    Location? location,
  }) = _StartTripDto;

  factory StartTripDto.fromJson(Map<String, dynamic> json) =>
      _$StartTripDtoFromJson(json);
}

/// 운행 완료 DTO
@freezed
class CompleteTripDto with _$CompleteTripDto {
  const factory CompleteTripDto({
    Location? location,
  }) = _CompleteTripDto;

  factory CompleteTripDto.fromJson(Map<String, dynamic> json) =>
      _$CompleteTripDtoFromJson(json);
}

/// 운행 취소 DTO
@freezed
class CancelTripDto with _$CancelTripDto {
  const factory CancelTripDto({
    required String reason,
  }) = _CancelTripDto;

  factory CancelTripDto.fromJson(Map<String, dynamic> json) =>
      _$CancelTripDtoFromJson(json);
}
