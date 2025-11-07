import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/services/vehicle_repository.dart';

// ========== Repository Provider ==========

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VehicleRepository(apiClient);
});

// ========== Vehicle List Provider ==========

/// 차량 목록 조회 파라미터
class VehicleListParams {
  final int page;
  final int limit;
  final String? search;
  final VehicleStatus? status;
  final VehicleType? type;

  VehicleListParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.type,
  });

  VehicleListParams copyWith({
    int? page,
    int? limit,
    String? search,
    VehicleStatus? status,
    VehicleType? type,
  }) {
    return VehicleListParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleListParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          status == other.status &&
          type == other.type;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      search.hashCode ^
      status.hashCode ^
      type.hashCode;
}

/// 차량 목록 상태
class VehicleListState {
  final PaginatedVehicles? data;
  final bool isLoading;
  final String? error;
  final VehicleListParams params;

  VehicleListState({
    this.data,
    this.isLoading = false,
    this.error,
    required this.params,
  });

  VehicleListState copyWith({
    PaginatedVehicles? data,
    bool? isLoading,
    String? error,
    VehicleListParams? params,
  }) {
    return VehicleListState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      params: params ?? this.params,
    );
  }
}

/// 차량 목록 Provider
class VehicleListNotifier extends StateNotifier<VehicleListState> {
  final VehicleRepository _repository;

  VehicleListNotifier(this._repository)
      : super(VehicleListState(params: VehicleListParams())) {
    loadVehicles();
  }

  /// 차량 목록 로드
  Future<void> loadVehicles() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getVehicles(
        page: state.params.page,
        limit: state.params.limit,
        search: state.params.search,
        status: state.params.status,
        type: state.params.type,
      );

      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('차량 목록 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 검색어 변경
  void setSearch(String? search) {
    state = state.copyWith(
      params: state.params.copyWith(search: search, page: 1),
    );
    loadVehicles();
  }

  /// 상태 필터 변경
  void setStatusFilter(VehicleStatus? status) {
    state = state.copyWith(
      params: state.params.copyWith(status: status, page: 1),
    );
    loadVehicles();
  }

  /// 차량 타입 필터 변경
  void setTypeFilter(VehicleType? type) {
    state = state.copyWith(
      params: state.params.copyWith(type: type, page: 1),
    );
    loadVehicles();
  }

  /// 페이지 변경
  void setPage(int page) {
    state = state.copyWith(
      params: state.params.copyWith(page: page),
    );
    loadVehicles();
  }

  /// 필터 초기화
  void resetFilters() {
    state = VehicleListState(params: VehicleListParams());
    loadVehicles();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadVehicles();
  }
}

final vehicleListProvider =
    StateNotifierProvider<VehicleListNotifier, VehicleListState>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleListNotifier(repository);
});

// ========== Single Vehicle Provider ==========

/// 개별 차량 상태
class VehicleState {
  final Vehicle? data;
  final bool isLoading;
  final String? error;

  VehicleState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  VehicleState copyWith({
    Vehicle? data,
    bool? isLoading,
    String? error,
  }) {
    return VehicleState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 개별 차량 Provider
class VehicleNotifier extends StateNotifier<VehicleState> {
  final VehicleRepository _repository;
  final String vehicleId;

  VehicleNotifier(this._repository, this.vehicleId)
      : super(VehicleState()) {
    loadVehicle();
  }

  /// 차량 상세 로드
  Future<void> loadVehicle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getVehicle(vehicleId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('차량 상세 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadVehicle();
  }
}

final vehicleProvider =
    StateNotifierProvider.family<VehicleNotifier, VehicleState, String>(
        (ref, vehicleId) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleNotifier(repository, vehicleId);
});

// ========== Vehicle CRUD Actions Provider ==========

/// 차량 CRUD 액션
class VehicleActions {
  final VehicleRepository _repository;
  final Ref _ref;

  VehicleActions(this._repository, this._ref);

  /// 차량 생성
  Future<Vehicle> createVehicle(CreateVehicleDto dto) async {
    final vehicle = await _repository.createVehicle(dto);
    // 차량 목록 새로고침
    _ref.read(vehicleListProvider.notifier).refresh();
    return vehicle;
  }

  /// 차량 수정
  Future<Vehicle> updateVehicle(String id, UpdateVehicleDto dto) async {
    final vehicle = await _repository.updateVehicle(id, dto);
    // 차량 목록 새로고침
    _ref.read(vehicleListProvider.notifier).refresh();
    return vehicle;
  }

  /// 차량 삭제
  Future<void> deleteVehicle(String id) async {
    await _repository.deleteVehicle(id);
    // 차량 목록 새로고침
    _ref.read(vehicleListProvider.notifier).refresh();
  }
}

final vehicleActionsProvider = Provider<VehicleActions>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleActions(repository, ref);
});
