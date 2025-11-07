import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/driver.dart';

/// 기사 목록 응답
class PaginatedDrivers {
  final List<Driver> drivers;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginatedDrivers({
    required this.drivers,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
}

/// 기사 Repository
class DriverRepository {
  final ApiClient _apiClient;

  DriverRepository(this._apiClient);

  /// 기사 목록 조회
  Future<PaginatedDrivers> getDrivers({
    int page = 1,
    int limit = 20,
    DriverStatus? status,
    String? search,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockDrivers(page: page, limit: limit, status: status, search: search);
    }

    final response = await _apiClient.get(
      ApiConstants.drivers,
      queryParameters: {
        'page': page,
        'page_size': limit,
        if (status != null) 'status': status.name,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => (json as List).map((e) => Driver.fromJson(e)).toList(),
    );

    final pagination = response.data['pagination'];

    return PaginatedDrivers(
      drivers: apiResponse.data as List<Driver>,
      page: pagination['page'],
      pageSize: pagination['page_size'],
      totalItems: pagination['total_items'],
      totalPages: pagination['total_pages'],
    );
  }

  /// 기사 상세 조회
  Future<Driver> getDriverById(String id) async {
    if (AppConstants.useMockApi) {
      return _generateMockDriver(id);
    }

    final response = await _apiClient.get(ApiConstants.driverById(id));
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Driver.fromJson(json),
    );

    return apiResponse.data as Driver;
  }

  /// 기사 등록
  Future<Driver> createDriver(CreateDriverDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 새 기사 생성 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockDriver('driver-new');
    }

    final response = await _apiClient.post(
      ApiConstants.drivers,
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Driver.fromJson(json),
    );

    return apiResponse.data as Driver;
  }

  /// 기사 수정
  Future<Driver> updateDriver(String id, UpdateDriverDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 기존 기사 반환
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockDriver(id);
    }

    final response = await _apiClient.put(
      ApiConstants.driverById(id),
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => Driver.fromJson(json),
    );

    return apiResponse.data as Driver;
  }

  /// 기사 삭제
  Future<void> deleteDriver(String id) async {
    if (AppConstants.useMockApi) {
      // Mock: 삭제 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _apiClient.delete(ApiConstants.driverById(id));
  }

  // ========== Mock 데이터 ==========

  /// Mock 기사 목록
  Future<PaginatedDrivers> _getMockDrivers({
    int page = 1,
    int limit = 20,
    DriverStatus? status,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 20명의 Mock 기사 생성
    final allDrivers = List.generate(20, (index) => _generateMockDriver('driver-$index'));

    // 상태 필터링
    var filteredDrivers = status != null
        ? allDrivers.where((d) => d.status == status).toList()
        : allDrivers;

    // 검색 필터링
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredDrivers = filteredDrivers.where((d) {
        return d.name.toLowerCase().contains(searchLower) ||
            d.phone.contains(search) ||
            (d.email?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // 페이지네이션
    final totalItems = filteredDrivers.length;
    final totalPages = (totalItems / limit).ceil();
    final start = (page - 1) * limit;
    final end = start + limit;
    final paginatedDrivers = filteredDrivers.sublist(
      start,
      end > totalItems ? totalItems : end,
    );

    return PaginatedDrivers(
      drivers: paginatedDrivers,
      page: page,
      pageSize: limit,
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  /// Mock 기사 생성
  Driver _generateMockDriver(String id) {
    final index = int.tryParse(id.replaceAll('driver-', '')) ?? 0;

    final names = [
      '김철수', '이영희', '박민수', '최수진', '정우성',
      '강호동', '유재석', '박나래', '송강호', '김혜수',
      '한지민', '조인성', '이병헌', '전지현', '배용준',
      '김태희', '현빈', '송혜교', '공유', '이민호',
    ];

    final name = names[index % names.length];

    // 상태: 대부분 활동중
    DriverStatus status;
    if (index % 7 == 0) {
      status = DriverStatus.onLeave;
    } else if (index % 11 == 0) {
      status = DriverStatus.inactive;
    } else {
      status = DriverStatus.active;
    }

    // 면허 종류
    final licenseTypes = [
      LicenseType.type1Regular,
      LicenseType.type1Large,
      LicenseType.type2Regular,
    ];
    final licenseType = licenseTypes[index % 3];

    // 면허번호 생성 (형식: 11-12-345678-90)
    final licenseNumber = '${11 + (index % 8)}-${12 + (index % 6)}-${345678 + index}-${90 + (index % 10)}';

    // 면허 만료일 (일부는 만료 임박)
    DateTime licenseExpiry;
    if (index % 5 == 0) {
      // 30일 이내 만료
      licenseExpiry = DateTime.now().add(Duration(days: 10 + (index % 20)));
    } else if (index % 5 == 1) {
      // 이미 만료
      licenseExpiry = DateTime.now().subtract(Duration(days: 10 + (index % 30)));
    } else {
      // 여유 있음
      licenseExpiry = DateTime.now().add(Duration(days: 200 + (index * 30)));
    }

    // 입사일
    final hireDate = DateTime.now().subtract(Duration(days: 365 + (index * 100)));

    return Driver(
      id: id,
      name: name,
      phone: '010-${1000 + index * 11}-${2000 + index * 13}',
      email: status != DriverStatus.inactive
          ? '${name.toLowerCase().replaceAll(' ', '')}${index}@example.com'
          : null,
      status: status,
      licenseNumber: licenseNumber,
      licenseType: licenseType,
      licenseExpiry: licenseExpiry,
      hireDate: hireDate,
      terminationDate: status == DriverStatus.inactive
          ? DateTime.now().subtract(Duration(days: 30 + (index * 10)))
          : null,
      address: status != DriverStatus.inactive ? '서울시 ${['강남구', '서초구', '송파구', '마포구'][index % 4]} ${index}번지' : null,
      emergencyContact: status != DriverStatus.inactive ? '010-${3000 + index * 7}-${4000 + index * 9}' : null,
      notes: index % 3 == 0 ? '안전운전 모범 기사' : null,
      createdAt: hireDate,
      updatedAt: DateTime.now().subtract(Duration(days: index)),
    );
  }
}

/// DriverRepository Provider
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DriverRepository(apiClient);
});
