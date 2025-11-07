import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_response.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/route.dart';

/// 경로 목록 응답
class PaginatedRoutes {
  final List<RouteModel> routes;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginatedRoutes({
    required this.routes,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });
}

/// 경로 Repository
class RouteRepository {
  final ApiClient _apiClient;

  RouteRepository(this._apiClient);

  /// 경로 목록 조회
  Future<PaginatedRoutes> getRoutes({
    int page = 1,
    int limit = 20,
    RouteStatus? status,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockRoutes(page: page, limit: limit, status: status);
    }

    final response = await _apiClient.get(
      ApiConstants.routes,
      queryParameters: {
        'page': page,
        'page_size': limit,
        if (status != null) 'status': status.name,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => (json as List).map((e) => RouteModel.fromJson(e)).toList(),
    );

    final pagination = response.data['pagination'];

    return PaginatedRoutes(
      routes: apiResponse.data as List<RouteModel>,
      page: pagination['page'],
      pageSize: pagination['page_size'],
      totalItems: pagination['total_items'],
      totalPages: pagination['total_pages'],
    );
  }

  /// 경로 상세 조회
  Future<RouteModel> getRouteById(String id) async {
    if (AppConstants.useMockApi) {
      return _generateMockRoute(id);
    }

    final response = await _apiClient.get(ApiConstants.routeById(id));
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => RouteModel.fromJson(json),
    );

    return apiResponse.data as RouteModel;
  }

  /// 경로별 정류장 조회
  Future<List<Stop>> getRouteStops(String routeId) async {
    if (AppConstants.useMockApi) {
      return _generateMockStops(routeId);
    }

    final response = await _apiClient.get(ApiConstants.routeStops(routeId));
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => (json as List).map((e) => Stop.fromJson(e)).toList(),
    );

    return apiResponse.data as List<Stop>;
  }

  /// 경로 생성
  Future<RouteModel> createRoute(CreateRouteDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 새 경로 생성 시뮬레이션
      return _generateMockRoute('route-new');
    }

    final response = await _apiClient.post(
      ApiConstants.routes,
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => RouteModel.fromJson(json),
    );

    return apiResponse.data as RouteModel;
  }

  /// 경로 수정
  Future<RouteModel> updateRoute(String id, UpdateRouteDto dto) async {
    if (AppConstants.useMockApi) {
      // Mock: 기존 경로 반환
      return _generateMockRoute(id);
    }

    final response = await _apiClient.put(
      ApiConstants.routeById(id),
      data: dto.toJson(),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data,
      (json) => RouteModel.fromJson(json),
    );

    return apiResponse.data as RouteModel;
  }

  /// 경로 삭제
  Future<void> deleteRoute(String id) async {
    if (AppConstants.useMockApi) {
      // Mock: 삭제 시뮬레이션
      return;
    }

    await _apiClient.delete(ApiConstants.routeById(id));
  }

  // ========== Mock 데이터 ==========

  /// Mock 경로 목록
  Future<PaginatedRoutes> _getMockRoutes({
    int page = 1,
    int limit = 20,
    RouteStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 10개의 Mock 경로 생성
    final allRoutes = List.generate(10, (index) => _generateMockRoute('route-$index'));

    // 상태 필터링
    final filteredRoutes = status != null
        ? allRoutes.where((r) => r.status == status).toList()
        : allRoutes;

    // 페이지네이션
    final totalItems = filteredRoutes.length;
    final totalPages = (totalItems / limit).ceil();
    final start = (page - 1) * limit;
    final end = start + limit;
    final paginatedRoutes = filteredRoutes.sublist(
      start,
      end > totalItems ? totalItems : end,
    );

    return PaginatedRoutes(
      routes: paginatedRoutes,
      page: page,
      pageSize: limit,
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  /// Mock 경로 생성
  RouteModel _generateMockRoute(String id) {
    final index = int.tryParse(id.replaceAll('route-', '')) ?? 0;
    final routes = [
      ('A코스', '오전 등원 A코스', 45, 15000),
      ('B코스', '오전 등원 B코스', 40, 12000),
      ('C코스', '오후 하원 C코스', 50, 18000),
      ('D코스', '오후 하원 D코스', 35, 10000),
      ('E코스', '주말 특별 코스', 60, 20000),
      ('F코스', '강남 순환 코스', 55, 16000),
      ('G코스', '서초 순환 코스', 42, 13000),
      ('H코스', '송파 순환 코스', 38, 11000),
      ('I코스', '마포 순환 코스', 48, 14000),
      ('J코스', '용산 순환 코스', 52, 17000),
    ];

    final routeData = routes[index % routes.length];

    return RouteModel(
      id: id,
      name: routeData.$1,
      description: routeData.$2,
      status: index % 5 == 4 ? RouteStatus.inactive : RouteStatus.active,
      stops: _generateMockStops(id),
      estimatedTime: routeData.$3,
      totalDistance: routeData.$4,
      createdAt: DateTime.now().subtract(Duration(days: 30 + index)),
      updatedAt: DateTime.now().subtract(Duration(days: index)),
    );
  }

  /// Mock 정류장 생성
  List<Stop> _generateMockStops(String routeId) {
    final routeIndex = int.tryParse(routeId.replaceAll('route-', '')) ?? 0;

    // 서울 주요 위치 좌표 (강남, 서초, 송파, 마포, 용산 등)
    final locations = [
      ('강남역', '서울시 강남구 강남대로 396', 37.4979, 127.0276),
      ('삼성역', '서울시 강남구 삼성로 511', 37.5085, 127.0632),
      ('역삼역', '서울시 강남구 강남대로 396', 37.5003, 127.0365),
      ('선릉역', '서울시 강남구 선릉로 428', 37.5045, 127.0490),
      ('서초역', '서울시 서초구 서초대로 397', 37.4836, 127.0103),
      ('교대역', '서울시 서초구 남부순환로 2533', 37.4935, 127.0141),
      ('잠실역', '서울시 송파구 올림픽로 지하 265', 37.5133, 127.1000),
      ('석촌역', '서울시 송파구 송파대로 지하 111', 37.5056, 127.1055),
      ('홍대입구역', '서울시 마포구 양화로 160', 37.5572, 126.9236),
      ('합정역', '서울시 마포구 양화로 45', 37.5497, 126.9135),
      ('이촌역', '서울시 용산구 이촌로 40', 37.5222, 126.9658),
      ('서빙고역', '서울시 용산구 서빙고로 67', 37.5176, 126.9948),
    ];

    // 각 경로마다 4-6개의 정류장
    final stopCount = 4 + (routeIndex % 3);
    final startIndex = routeIndex * 2;

    return List.generate(stopCount, (index) {
      final locationIndex = (startIndex + index) % locations.length;
      final location = locations[locationIndex];

      return Stop(
        id: 'stop-$routeId-$index',
        routeId: routeId,
        name: location.$1,
        address: location.$2,
        order: index + 1,
        latitude: location.$3,
        longitude: location.$4,
        estimatedArrivalTime: (index + 1) * 5 + (routeIndex % 3) * 2, // 5-20분 간격
        notes: index == 0 ? '출발지' : (index == stopCount - 1 ? '도착지' : null),
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      );
    });
  }
}

/// RouteRepository Provider
final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RouteRepository(apiClient);
});
