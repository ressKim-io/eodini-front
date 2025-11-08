import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/schedule.dart';

/// 일정 목록 응답
class PaginatedSchedules {
  final List<Schedule> schedules;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginatedSchedules({
    required this.schedules,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
}

/// 일정 Repository
class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository(this._apiClient);

  /// 일정 목록 조회
  Future<PaginatedSchedules> getSchedules({
    int page = 1,
    int limit = 20,
    ScheduleStatus? status,
    TimeSlot? timeSlot,
    String? routeId,
    String? vehicleId,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockSchedules(
        page: page,
        limit: limit,
        status: status,
        timeSlot: timeSlot,
        routeId: routeId,
        vehicleId: vehicleId,
      );
    }

    final response = await _apiClient.get(
      ApiConstants.schedules,
      queryParameters: {
        'page': page,
        'page_size': limit,
        if (status != null) 'status': status.name,
        if (timeSlot != null) 'time_slot': timeSlot.name,
        if (routeId != null) 'route_id': routeId,
        if (vehicleId != null) 'vehicle_id': vehicleId,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) =>
          (json as List).map((e) => Schedule.fromJson(e)).toList(),
    );

    final pagination = response.data['pagination'];

    return PaginatedSchedules(
      schedules: apiResponse.data as List<Schedule>,
      page: pagination['page'],
      pageSize: pagination['page_size'],
      totalItems: pagination['total_items'],
      totalPages: pagination['total_pages'],
    );
  }

  /// 일정 상세 조회
  Future<Schedule> getScheduleById(String id) async {
    if (AppConstants.useMockApi) {
      return _generateMockSchedule(id);
    }

    final response = await _apiClient.get(ApiConstants.scheduleById(id));
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Schedule.fromJson(json as Map<String, dynamic>),
    );

    return apiResponse.data as Schedule;
  }

  /// 일정 생성
  Future<Schedule> createSchedule(CreateScheduleDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 새 일정 생성 시뮬레이션
      return _generateMockSchedule('schedule-new');
    }

    final response = await _apiClient.post(
      ApiConstants.schedules,
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Schedule.fromJson(json as Map<String, dynamic>),
    );

    return apiResponse.data as Schedule;
  }

  /// 일정 수정
  Future<Schedule> updateSchedule(String id, UpdateScheduleDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 기존 일정 반환
      return _generateMockSchedule(id);
    }

    final response = await _apiClient.put(
      ApiConstants.scheduleById(id),
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Schedule.fromJson(json as Map<String, dynamic>),
    );

    return apiResponse.data as Schedule;
  }

  /// 일정 삭제
  Future<void> deleteSchedule(String id) async {
    if (AppConstants.useMockApi) {
      // Mock: 삭제 시뮬레이션
      return;
    }

    await _apiClient.delete(ApiConstants.scheduleById(id));
  }

  // ========== Mock 데이터 ==========

  /// Mock 일정 목록
  Future<PaginatedSchedules> _getMockSchedules({
    int page = 1,
    int limit = 20,
    ScheduleStatus? status,
    TimeSlot? timeSlot,
    String? routeId,
    String? vehicleId,
  }) async {
    // 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    // 20개의 Mock 일정 생성
    final allSchedules = List.generate(
      20,
      (index) => _generateMockSchedule('schedule-${index + 1}'),
    );

    // 필터링
    final filtered = allSchedules.where((schedule) {
      if (status != null && schedule.status != status) return false;
      if (timeSlot != null && schedule.timeSlot != timeSlot) return false;
      if (routeId != null && schedule.routeId != routeId) return false;
      if (vehicleId != null && schedule.vehicleId != vehicleId) return false;
      return true;
    }).toList();

    // 페이지네이션
    final total = filtered.length;
    final totalPages = (total / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, total);

    final schedules = startIndex < total
        ? filtered.sublist(startIndex, endIndex)
        : <Schedule>[];

    return PaginatedSchedules(
      schedules: schedules,
      page: page,
      pageSize: limit,
      totalItems: total,
      totalPages: totalPages,
    );
  }

  /// Mock 일정 데이터 생성
  Schedule _generateMockSchedule(String id) {
    final index = int.tryParse(id.replaceAll('schedule-', '')) ?? 1;
    final statuses = ScheduleStatus.values;
    final timeSlots = TimeSlot.values;

    final status = statuses[index % statuses.length];
    final timeSlot = timeSlots[index % timeSlots.length];

    // 시간대별 출발 시간
    final startTime = switch (timeSlot) {
      TimeSlot.morning => '08:00',
      TimeSlot.afternoon => '14:00',
      TimeSlot.evening => '18:00',
    };

    // 요일 패턴
    final daysOfWeek = switch (index % 4) {
      0 => [1, 2, 3, 4, 5], // 평일 (월~금)
      1 => [1, 3, 5], // 월, 수, 금
      2 => [2, 4], // 화, 목
      _ => [1, 2, 3, 4, 5, 6], // 월~토
    };

    final now = DateTime.now();
    final validFrom = now.subtract(Duration(days: 30 - (index % 30)));
    final validTo = now.add(Duration(days: 180 + (index % 180)));

    return Schedule(
      id: id,
      name: _getScheduleName(timeSlot, index),
      description: _getScheduleDescription(timeSlot, index),
      status: status,
      startTime: startTime,
      timeSlot: timeSlot,
      daysOfWeek: daysOfWeek,
      routeId: 'route-${(index % 10) + 1}',
      vehicleId: 'vehicle-${(index % 35) + 1}',
      defaultDriverId: 'driver-${(index % 20) + 1}',
      defaultAttendantId: index % 3 == 0 ? 'driver-${(index % 20) + 2}' : null,
      validFrom: validFrom,
      validTo: validTo,
      createdAt: now.subtract(Duration(days: 30)),
      updatedAt: now.subtract(Duration(days: index % 30)),
    );
  }

  String _getScheduleName(TimeSlot timeSlot, int index) {
    final slotName = switch (timeSlot) {
      TimeSlot.morning => '등교',
      TimeSlot.afternoon => '하교',
      TimeSlot.evening => '귀가',
    };
    return '$slotName 노선 ${index % 5 + 1}호';
  }

  String _getScheduleDescription(TimeSlot timeSlot, int index) {
    final areas = ['강남구', '서초구', '송파구', '마포구', '용산구', '영등포구', '관악구'];
    final area = areas[index % areas.length];
    final slotDesc = switch (timeSlot) {
      TimeSlot.morning => '오전',
      TimeSlot.afternoon => '오후',
      TimeSlot.evening => '저녁',
    };
    return '$area $slotDesc 운행 일정';
  }
}

/// ScheduleRepository Provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleRepository(apiClient);
});
