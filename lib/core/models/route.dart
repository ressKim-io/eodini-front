import 'package:freezed_annotation/freezed_annotation.dart';

part 'route.freezed.dart';
part 'route.g.dart';

/// 경로 상태
enum RouteStatus {
  @JsonValue('active')
  active, // 사용 중
  @JsonValue('inactive')
  inactive, // 미사용
}

/// 경로 모델
@freezed
class RouteModel with _$RouteModel {
  const factory RouteModel({
    required String id,
    required String name,
    required String description,
    required RouteStatus status,
    List<Stop>? stops,
    @JsonKey(name: 'estimated_time') required int estimatedTime,
    @JsonKey(name: 'total_distance') int? totalDistance,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
}

/// 정류장 모델
@freezed
class Stop with _$Stop {
  const factory Stop({
    required String id,
    @JsonKey(name: 'route_id') required String routeId,
    required String name,
    required String address,
    required int order,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'estimated_arrival_time') required int estimatedArrivalTime,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Stop;

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
}

/// 경로 생성 DTO
@freezed
class CreateRouteDto with _$CreateRouteDto {
  const factory CreateRouteDto({
    required String name,
    required String description,
    @JsonKey(name: 'estimated_time') required int estimatedTime,
    @JsonKey(name: 'total_distance') int? totalDistance,
  }) = _CreateRouteDto;

  factory CreateRouteDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRouteDtoFromJson(json);
}

/// 경로 업데이트 DTO
@freezed
class UpdateRouteDto with _$UpdateRouteDto {
  const factory UpdateRouteDto({
    String? name,
    String? description,
    RouteStatus? status,
    @JsonKey(name: 'estimated_time') int? estimatedTime,
    @JsonKey(name: 'total_distance') int? totalDistance,
  }) = _UpdateRouteDto;

  factory UpdateRouteDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateRouteDtoFromJson(json);
}

/// 정류장 생성 DTO
@freezed
class CreateStopDto with _$CreateStopDto {
  const factory CreateStopDto({
    @JsonKey(name: 'route_id') required String routeId,
    required String name,
    required String address,
    required int order,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'estimated_arrival_time') required int estimatedArrivalTime,
    String? notes,
  }) = _CreateStopDto;

  factory CreateStopDto.fromJson(Map<String, dynamic> json) =>
      _$CreateStopDtoFromJson(json);
}

/// 정류장 업데이트 DTO
@freezed
class UpdateStopDto with _$UpdateStopDto {
  const factory UpdateStopDto({
    String? name,
    String? address,
    int? order,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'estimated_arrival_time') int? estimatedArrivalTime,
    String? notes,
  }) = _UpdateStopDto;

  factory UpdateStopDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateStopDtoFromJson(json);
}
