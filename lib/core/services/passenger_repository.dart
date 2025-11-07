import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../models/passenger.dart';

/// 탑승자 관리 Repository
class PassengerRepository {
  final ApiClient _apiClient;

  PassengerRepository(this._apiClient);

  /// 탑승자 목록 조회 (페이지네이션, 검색, 필터)
  Future<PaginatedPassengers> getPassengers({
    int page = 1,
    int limit = 20,
    String? search,
    PassengerStatus? status,
    String? routeId,
  }) async {
    if (AppConstants.useMockApi) {
      return _getMockPassengers(
        page: page,
        limit: limit,
        search: search,
        status: status,
        routeId: routeId,
      );
    }

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status.name,
      if (routeId != null) 'route_id': routeId,
    };

    final response = await _apiClient.get(
      '/passengers',
      queryParameters: queryParams,
    );

    return PaginatedPassengers.fromJson(response.data);
  }

  /// 탑승자 상세 조회
  Future<Passenger> getPassenger(String id) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockPassenger(id);
    }

    final response = await _apiClient.get('/passengers/$id');
    return Passenger.fromJson(response.data);
  }

  /// 탑승자 생성
  Future<Passenger> createPassenger(CreatePassengerDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      return Passenger(
        id: 'passenger-${DateTime.now().millisecondsSinceEpoch}',
        name: dto.name,
        age: dto.age,
        gender: dto.gender,
        status: PassengerStatus.active,
        assignedRouteId: 'route-1', // 기본 경로
        assignedStopId: 'stop-1', // 기본 정류장
        stopOrder: 1,
        guardianName: dto.guardianName,
        guardianPhone: dto.guardianPhone,
        guardianEmail: dto.guardianEmail,
        guardianRelation: dto.guardianRelation,
        emergencyContact: dto.emergencyContact,
        emergencyRelation: dto.emergencyRelation,
        address: dto.address,
        medicalNotes: dto.medicalNotes,
        notes: dto.notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post(
      '/passengers',
      data: dto.toJson(),
    );
    return Passenger.fromJson(response.data);
  }

  /// 탑승자 수정
  Future<Passenger> updatePassenger(String id, UpdatePassengerDto dto) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = _generateMockPassenger(id);
      return Passenger(
        id: existing.id,
        name: dto.name ?? existing.name,
        age: dto.age ?? existing.age,
        gender: dto.gender ?? existing.gender,
        status: dto.status ?? existing.status,
        assignedRouteId: existing.assignedRouteId,
        assignedStopId: existing.assignedStopId,
        stopOrder: existing.stopOrder,
        guardianName: dto.guardianName ?? existing.guardianName,
        guardianPhone: dto.guardianPhone ?? existing.guardianPhone,
        guardianEmail: dto.guardianEmail ?? existing.guardianEmail,
        guardianRelation: dto.guardianRelation ?? existing.guardianRelation,
        emergencyContact: dto.emergencyContact ?? existing.emergencyContact,
        emergencyRelation: dto.emergencyRelation ?? existing.emergencyRelation,
        address: dto.address ?? existing.address,
        medicalNotes: dto.medicalNotes ?? existing.medicalNotes,
        notes: dto.notes ?? existing.notes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.put(
      '/passengers/$id',
      data: dto.toJson(),
    );
    return Passenger.fromJson(response.data);
  }

  /// 탑승자 삭제
  Future<void> deletePassenger(String id) async {
    if (AppConstants.useMockApi) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _apiClient.delete('/passengers/$id');
  }

  // ========== Mock 데이터 생성 ==========

  /// Mock 탑승자 목록 생성
  Future<PaginatedPassengers> _getMockPassengers({
    required int page,
    required int limit,
    String? search,
    PassengerStatus? status,
    String? routeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 전체 Mock 데이터 생성
    final allPassengers = List.generate(
      50,
      (index) => _generateMockPassenger('passenger-${index + 1}'),
    );

    // 필터링
    var filtered = allPassengers.where((passenger) {
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        if (!passenger.name.toLowerCase().contains(searchLower) &&
            !passenger.guardianName.toLowerCase().contains(searchLower) &&
            !passenger.guardianPhone.contains(searchLower)) {
          return false;
        }
      }
      if (status != null && passenger.status != status) return false;
      if (routeId != null && passenger.assignedRouteId != routeId) {
        return false;
      }
      return true;
    }).toList();

    // 페이지네이션
    final total = filtered.length;
    final totalPages = (total / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, total);

    final items = startIndex < total
        ? filtered.sublist(startIndex, endIndex)
        : <Passenger>[];

    return PaginatedPassengers(
      items: items,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
    );
  }

  /// Mock 탑승자 데이터 생성
  Passenger _generateMockPassenger(String id) {
    final index = int.tryParse(id.replaceAll('passenger-', '')) ?? 1;
    final statuses = PassengerStatus.values;

    final lastNames = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임'];
    final firstNames = ['서연', '민준', '지우', '하준', '서준', '예준', '도윤', '시우', '주원', '하윤'];

    final genders = ['남', '여'];
    final relations = ['아버지', '어머니', '할머니', '할아버지', '이모', '삼촌'];

    final addresses = [
      '서울시 강남구 역삼동 123-45',
      '서울시 서초구 반포동 67-89',
      '서울시 송파구 잠실동 234-56',
      '서울시 마포구 상암동 345-67',
      '경기도 성남시 분당구 정자동 456-78',
    ];

    final medicalNotesList = [
      null,
      '알레르기: 땅콩',
      '천식 있음',
      '심장 질환 주의',
      '당뇨 - 정기적인 간식 필요',
    ];

    final lastName = lastNames[index % lastNames.length];
    final firstName = firstNames[index % firstNames.length];
    final gender = genders[index % genders.length];
    final relation = relations[index % relations.length];
    final status = statuses[index % statuses.length];

    return Passenger(
      id: id,
      name: '$lastName$firstName',
      age: 7 + (index % 12), // 7-18세
      gender: gender,
      status: status,
      assignedRouteId: 'route-${(index % 5) + 1}',
      assignedStopId: 'stop-${(index % 10) + 1}',
      stopOrder: (index % 10) + 1,
      guardianName: '$lastName${relation == '아버지' || relation == '어머니' ? '' : '○○'}($relation)',
      guardianPhone: '010-${(1000 + index).toString().padLeft(4, '0')}-${(5000 + index).toString().padLeft(4, '0')}',
      guardianEmail: index % 3 == 0
          ? 'parent$index@example.com'
          : null,
      guardianRelation: relation,
      emergencyContact: index % 2 == 0
          ? '010-${(9000 + index).toString().padLeft(4, '0')}-${(1000 + index).toString().padLeft(4, '0')}'
          : null,
      emergencyRelation: index % 2 == 0 ? '조부모' : null,
      address: addresses[index % addresses.length],
      medicalNotes: medicalNotesList[index % medicalNotesList.length],
      notes: index % 5 == 0 ? '학원 후 하차 - 목요일 제외' : null,
      createdAt: DateTime.now().subtract(Duration(days: index * 30)),
      updatedAt: DateTime.now().subtract(Duration(days: index * 5)),
    );
  }
}

/// 페이지네이션된 탑승자 목록
class PaginatedPassengers {
  final List<Passenger> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedPassengers({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedPassengers.fromJson(Map<String, dynamic> json) {
    return PaginatedPassengers(
      items: (json['items'] as List)
          .map((item) => Passenger.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'],
    );
  }
}
