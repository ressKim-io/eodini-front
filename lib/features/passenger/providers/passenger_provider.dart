import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/passenger.dart';
import '../../../core/services/passenger_repository.dart';

// ========== Repository Provider ==========

final passengerRepositoryProvider = Provider<PassengerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PassengerRepository(apiClient);
});

// ========== Passenger List Provider ==========

/// 탑승자 목록 조회 파라미터
class PassengerListParams {
  final int page;
  final int limit;
  final String? search;
  final PassengerStatus? status;
  final String? routeId;

  PassengerListParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.routeId,
  });

  PassengerListParams copyWith({
    int? page,
    int? limit,
    String? search,
    PassengerStatus? status,
    String? routeId,
  }) {
    return PassengerListParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      status: status ?? this.status,
      routeId: routeId ?? this.routeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassengerListParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          status == other.status &&
          routeId == other.routeId;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      search.hashCode ^
      status.hashCode ^
      routeId.hashCode;
}

/// 탑승자 목록 상태
class PassengerListState {
  final PaginatedPassengers? data;
  final bool isLoading;
  final String? error;
  final PassengerListParams params;

  PassengerListState({
    this.data,
    this.isLoading = false,
    this.error,
    required this.params,
  });

  PassengerListState copyWith({
    PaginatedPassengers? data,
    bool? isLoading,
    String? error,
    PassengerListParams? params,
  }) {
    return PassengerListState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      params: params ?? this.params,
    );
  }
}

/// 탑승자 목록 Provider
class PassengerListNotifier extends StateNotifier<PassengerListState> {
  final PassengerRepository _repository;

  PassengerListNotifier(this._repository)
      : super(PassengerListState(params: PassengerListParams())) {
    loadPassengers();
  }

  /// 탑승자 목록 로드
  Future<void> loadPassengers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getPassengers(
        page: state.params.page,
        limit: state.params.limit,
        search: state.params.search,
        status: state.params.status,
        routeId: state.params.routeId,
      );

      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('탑승자 목록 로드 실패: $e');
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
    loadPassengers();
  }

  /// 상태 필터 변경
  void setStatusFilter(PassengerStatus? status) {
    state = state.copyWith(
      params: state.params.copyWith(status: status, page: 1),
    );
    loadPassengers();
  }

  /// 경로 필터 변경
  void setRouteFilter(String? routeId) {
    state = state.copyWith(
      params: state.params.copyWith(routeId: routeId, page: 1),
    );
    loadPassengers();
  }

  /// 페이지 변경
  void setPage(int page) {
    state = state.copyWith(
      params: state.params.copyWith(page: page),
    );
    loadPassengers();
  }

  /// 필터 초기화
  void resetFilters() {
    state = PassengerListState(params: PassengerListParams());
    loadPassengers();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadPassengers();
  }
}

final passengerListProvider =
    StateNotifierProvider<PassengerListNotifier, PassengerListState>((ref) {
  final repository = ref.watch(passengerRepositoryProvider);
  return PassengerListNotifier(repository);
});

// ========== Single Passenger Provider ==========

/// 개별 탑승자 상태
class PassengerState {
  final Passenger? data;
  final bool isLoading;
  final String? error;

  PassengerState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  PassengerState copyWith({
    Passenger? data,
    bool? isLoading,
    String? error,
  }) {
    return PassengerState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 개별 탑승자 Provider
class PassengerNotifier extends StateNotifier<PassengerState> {
  final PassengerRepository _repository;
  final String passengerId;

  PassengerNotifier(this._repository, this.passengerId)
      : super(PassengerState()) {
    loadPassenger();
  }

  /// 탑승자 상세 로드
  Future<void> loadPassenger() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getPassenger(passengerId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('탑승자 상세 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadPassenger();
  }
}

final passengerProvider =
    StateNotifierProvider.family<PassengerNotifier, PassengerState, String>(
        (ref, passengerId) {
  final repository = ref.watch(passengerRepositoryProvider);
  return PassengerNotifier(repository, passengerId);
});

// ========== Passenger CRUD Actions Provider ==========

/// 탑승자 CRUD 액션
class PassengerActions {
  final PassengerRepository _repository;
  final Ref _ref;

  PassengerActions(this._repository, this._ref);

  /// 탑승자 생성
  Future<Passenger> createPassenger(CreatePassengerDto dto) async {
    final passenger = await _repository.createPassenger(dto);
    // 탑승자 목록 새로고침
    _ref.read(passengerListProvider.notifier).refresh();
    return passenger;
  }

  /// 탑승자 수정
  Future<Passenger> updatePassenger(String id, UpdatePassengerDto dto) async {
    final passenger = await _repository.updatePassenger(id, dto);
    // 탑승자 목록 새로고침
    _ref.read(passengerListProvider.notifier).refresh();
    return passenger;
  }

  /// 탑승자 삭제
  Future<void> deletePassenger(String id) async {
    await _repository.deletePassenger(id);
    // 탑승자 목록 새로고침
    _ref.read(passengerListProvider.notifier).refresh();
  }
}

final passengerActionsProvider = Provider<PassengerActions>((ref) {
  final repository = ref.watch(passengerRepositoryProvider);
  return PassengerActions(repository, ref);
});
