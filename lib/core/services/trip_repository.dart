import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../models/trip.dart';

/// 운행 관리 Repository
class TripRepository {
  final ApiClient _apiClient;

  TripRepository(this._apiClient);

  /// 운행 목록 조회 (페이지네이션, 검색, 필터)
  Future<PaginatedTrips> getTrips({
    int page = 1,
    int limit = 20,
    TripStatus? status,
    String? vehicleId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockTrips(
        page: page,
        limit: limit,
        status: status,
        vehicleId: vehicleId,
        driverId: driverId,
        startDate: startDate,
        endDate: endDate,
      );
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (driverId != null) 'driver_id': driverId,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final response = await _apiClient.get(
      '/trips',
      queryParameters: queryParams,
    );

    return PaginatedTrips.fromJson(response.data);
  }

  /// 운행 상세 조회
  Future<Trip> getTrip(String id) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockTrip(id);
    }

    final response = await _apiClient.get('/trips/$id');
    return Trip.fromJson(response.data);
  }

  /// 운행 시작
  Future<Trip> startTrip(String id, StartTripDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = _generateMockTrip(id);
      return existing.copyWith(
        status: TripStatus.inProgress,
        startedAt: DateTime.now(),
        startedBy: dto.startedBy,
        actualStartLocation: dto.location,
      );
    }

    final response = await _apiClient.post(
      '/trips/$id/start',
      data: dto.toJson(),
    );
    return Trip.fromJson(response.data);
  }

  /// 운행 완료
  Future<Trip> completeTrip(String id, CompleteTripDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = _generateMockTrip(id);
      return existing.copyWith(
        status: TripStatus.completed,
        completedAt: DateTime.now(),
        actualEndLocation: dto.location,
        totalDistance: 15000, // Mock: 15km
      );
    }

    final response = await _apiClient.post(
      '/trips/$id/complete',
      data: dto.toJson(),
    );
    return Trip.fromJson(response.data);
  }

  /// 운행 취소
  Future<Trip> cancelTrip(String id, CancelTripDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = _generateMockTrip(id);
      return existing.copyWith(
        status: TripStatus.cancelled,
        cancelledAt: DateTime.now(),
        cancellationReason: dto.reason,
      );
    }

    final response = await _apiClient.post(
      '/trips/$id/cancel',
      data: dto.toJson(),
    );
    return Trip.fromJson(response.data);
  }

  /// 탑승자 탑승 체크
  Future<TripPassenger> boardPassenger(
    String tripId,
    String passengerId,
  ) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return TripPassenger(
        id: 'tp-$tripId-$passengerId',
        tripId: tripId,
        passengerId: passengerId,
        stopId: 'stop-1',
        boardedAt: DateTime.now(),
        isBoarded: true,
        isAlighted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post(
      '/trips/$tripId/passengers/$passengerId/board',
    );
    return TripPassenger.fromJson(response.data);
  }

  /// 탑승자 하차 체크
  Future<TripPassenger> alightPassenger(
    String tripId,
    String passengerId,
  ) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return TripPassenger(
        id: 'tp-$tripId-$passengerId',
        tripId: tripId,
        passengerId: passengerId,
        stopId: 'stop-1',
        boardedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        alightedAt: DateTime.now(),
        isBoarded: true,
        isAlighted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post(
      '/trips/$tripId/passengers/$passengerId/alight',
    );
    return TripPassenger.fromJson(response.data);
  }

  // ========== Mock 데이터 생성 ==========

  /// Mock 운행 목록 생성
  Future<PaginatedTrips> _getMockTrips({
    required int page,
    required int limit,
    TripStatus? status,
    String? vehicleId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 전체 Mock 데이터 생성
    final allTrips = List.generate(
      30,
      (index) => _generateMockTrip('trip-${index + 1}'),
    );

    // 필터링
    var filtered = allTrips.where((trip) {
      if (status != null && trip.status != status) return false;
      if (vehicleId != null && trip.vehicleId != vehicleId) return false;
      if (driverId != null && trip.assignedDriverId != driverId) return false;
      if (startDate != null && trip.date.isBefore(startDate)) return false;
      if (endDate != null && trip.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    // 최신순 정렬
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // 페이지네이션
    final total = filtered.length;
    final totalPages = (total / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, total);

    final items = startIndex < total
        ? filtered.sublist(startIndex, endIndex)
        : <Trip>[];

    return PaginatedTrips(
      items: items,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }

  /// Mock 운행 데이터 생성
  Trip _generateMockTrip(String id) {
    final index = int.tryParse(id.replaceAll('trip-', '')) ?? 1;
    final statuses = TripStatus.values;

    final status = statuses[index % statuses.length];
    final date = DateTime.now().subtract(Duration(days: index));

    // 탑승자 목록 생성
    final tripPassengers = List.generate(
      5 + (index % 10), // 5~14명
      (i) => TripPassenger(
        id: 'tp-$id-$i',
        tripId: id,
        passengerId: 'passenger-${i + 1}',
        stopId: 'stop-${(i % 5) + 1}',
        boardedAt: status == TripStatus.inProgress ||
                status == TripStatus.completed
            ? date.add(Duration(minutes: i * 5))
            : null,
        alightedAt: status == TripStatus.completed
            ? date.add(Duration(minutes: 30 + i * 5))
            : null,
        isBoarded: status == TripStatus.inProgress ||
            status == TripStatus.completed,
        isAlighted: status == TripStatus.completed,
        createdAt: date,
        updatedAt: date,
      ),
    );

    return Trip(
      id: id,
      scheduleId: 'schedule-${(index % 5) + 1}',
      date: date,
      status: status,
      vehicleId: 'vehicle-${(index % 10) + 1}',
      assignedDriverId: 'driver-${(index % 5) + 1}',
      assignedAttendantId: index % 3 == 0 ? 'attendant-${(index % 3) + 1}' : null,
      startedAt: status == TripStatus.inProgress ||
              status == TripStatus.completed
          ? date.add(const Duration(hours: 7))
          : null,
      completedAt: status == TripStatus.completed
          ? date.add(const Duration(hours: 8))
          : null,
      startedBy: status == TripStatus.inProgress ||
              status == TripStatus.completed
          ? 'driver-${(index % 5) + 1}'
          : null,
      actualStartLocation: status == TripStatus.inProgress ||
              status == TripStatus.completed
          ? Location(
              latitude: 37.5665 + (index % 10) * 0.01,
              longitude: 126.978 + (index % 10) * 0.01,
              timestamp: date.add(const Duration(hours: 7)),
            )
          : null,
      actualEndLocation: status == TripStatus.completed
          ? Location(
              latitude: 37.5665 + (index % 10) * 0.01 + 0.05,
              longitude: 126.978 + (index % 10) * 0.01 + 0.05,
              timestamp: date.add(const Duration(hours: 8)),
            )
          : null,
      totalDistance: status == TripStatus.completed ? 12000 + index * 1000 : null,
      tripPassengers: tripPassengers,
      cancelledAt: status == TripStatus.cancelled
          ? date.add(const Duration(hours: 6, minutes: 30))
          : null,
      cancellationReason: status == TripStatus.cancelled ? '차량 고장' : null,
      notes: index % 5 == 0 ? '우회 도로 이용' : null,
      createdAt: date.subtract(const Duration(days: 1)),
      updatedAt: date,
    );
  }
}

/// 페이지네이션된 운행 목록
class PaginatedTrips {
  final List<Trip> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedTrips({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedTrips.fromJson(Map<String, dynamic> json) {
    return PaginatedTrips(
      items: (json['items'] as List)
          .map((item) => Trip.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }
}
