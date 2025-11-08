import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../models/vehicle.dart';

/// 차량 관리 Repository
class VehicleRepository {
  final ApiClient _apiClient;

  VehicleRepository(this._apiClient);

  /// 차량 목록 조회 (페이지네이션, 검색, 필터)
  Future<PaginatedVehicles> getVehicles({
    int page = 1,
    int limit = 20,
    String? search,
    VehicleStatus? status,
    VehicleType? type,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockVehicles(
        page: page,
        limit: limit,
        search: search,
        status: status,
        type: type,
      );
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status.name,
      if (type != null) 'type': type.name,
    };

    final response = await _apiClient.get(
      '/vehicles',
      queryParameters: queryParams,
    );

    return PaginatedVehicles.fromJson(response.data);
  }

  /// 차량 상세 조회
  Future<Vehicle> getVehicle(String id) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockVehicle(id);
    }

    final response = await _apiClient.get('/vehicles/$id');
    return Vehicle.fromJson(response.data);
  }

  /// 차량 생성
  Future<Vehicle> createVehicle(CreateVehicleDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      return Vehicle(
        id: 'vehicle-${DateTime.now().millisecondsSinceEpoch}',
        plateNumber: dto.plateNumber,
        model: dto.model,
        manufacturer: dto.manufacturer,
        vehicleType: dto.vehicleType,
        capacity: dto.capacity,
        year: dto.year,
        color: dto.color,
        status: VehicleStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post(
      '/vehicles',
      data: dto.toJson(),
    );
    return Vehicle.fromJson(response.data);
  }

  /// 차량 수정
  Future<Vehicle> updateVehicle(String id, UpdateVehicleDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = _generateMockVehicle(id);
      return Vehicle(
        id: existing.id,
        plateNumber: existing.plateNumber,
        model: dto.model ?? existing.model,
        manufacturer: dto.manufacturer ?? existing.manufacturer,
        vehicleType: dto.vehicleType ?? existing.vehicleType,
        capacity: dto.capacity ?? existing.capacity,
        year: dto.year ?? existing.year,
        color: dto.color ?? existing.color,
        status: dto.status ?? existing.status,
        insuranceExpiry: dto.insuranceExpiry ?? existing.insuranceExpiry,
        inspectionExpiry: dto.inspectionExpiry ?? existing.inspectionExpiry,
        lastMaintenanceAt: existing.lastMaintenanceAt,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.put(
      '/vehicles/$id',
      data: dto.toJson(),
    );
    return Vehicle.fromJson(response.data);
  }

  /// 차량 삭제
  Future<void> deleteVehicle(String id) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _apiClient.delete('/vehicles/$id');
  }

  // ========== Mock 데이터 생성 ==========

  /// Mock 차량 목록 생성
  Future<PaginatedVehicles> _getMockVehicles({
    required int page,
    required int limit,
    String? search,
    VehicleStatus? status,
    VehicleType? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 전체 Mock 데이터 생성
    final allVehicles = List.generate(
      35,
      (index) => _generateMockVehicle('vehicle-${index + 1}'),
    );

    // 필터링
    var filtered = allVehicles.where((vehicle) {
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        if (!vehicle.plateNumber.toLowerCase().contains(searchLower) &&
            !vehicle.model.toLowerCase().contains(searchLower) &&
            !vehicle.manufacturer.toLowerCase().contains(searchLower)) {
          return false;
        }
      }
      if (status != null && vehicle.status != status) return false;
      if (type != null && vehicle.vehicleType != type) return false;
      return true;
    }).toList();

    // 페이지네이션
    final total = filtered.length;
    final totalPages = (total / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, total);

    final items = startIndex < total
        ? filtered.sublist(startIndex, endIndex)
        : <Vehicle>[];

    return PaginatedVehicles(
      items: items,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }

  /// Mock 차량 데이터 생성
  Vehicle _generateMockVehicle(String id) {
    final index = int.tryParse(id.replaceAll('vehicle-', '')) ?? 1;
    final types = VehicleType.values;
    final statuses = VehicleStatus.values;

    final manufacturers = ['현대', '기아', '쌍용', '르노삼성'];
    final models = {
      '현대': ['스타리아', '그랜드 스타렉스', '쏠라티'],
      '기아': ['카니발', '레이', '모닝'],
      '쌍용': ['투리스모', '로디우스'],
      '르노삼성': ['마스터'],
    };
    final colors = ['흰색', '검정', '은색', '파랑', '빨강'];

    final manufacturer = manufacturers[index % manufacturers.length];
    final modelList = models[manufacturer]!;
    final model = modelList[index % modelList.length];
    final type = types[index % types.length];
    final status = statuses[index % statuses.length];

    final capacity = type == VehicleType.bus
        ? 45
        : type == VehicleType.miniBus
            ? 25
            : type == VehicleType.van
                ? 12
                : 5;

    return Vehicle(
      id: id,
      plateNumber: '${index.toString().padLeft(2, '0')}가${(1000 + index).toString()}',
      model: model,
      manufacturer: manufacturer,
      vehicleType: type,
      capacity: capacity,
      year: 2020 + (index % 5),
      color: colors[index % colors.length],
      status: status,
      insuranceExpiry: DateTime.now().add(Duration(days: 30 * (index % 12))),
      inspectionExpiry: DateTime.now().add(Duration(days: 30 * (index % 12))),
      lastMaintenanceAt:
          DateTime.now().subtract(Duration(days: index * 10)),
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      updatedAt: DateTime.now().subtract(Duration(days: index * 5)),
    );
  }
}

/// 페이지네이션된 차량 목록
class PaginatedVehicles {
  final List<Vehicle> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedVehicles({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedVehicles.fromJson(Map<String, dynamic> json) {
    return PaginatedVehicles(
      items: (json['items'] as List)
          .map((item) => Vehicle.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }
}

/// VehicleRepository Provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VehicleRepository(apiClient);
});
