import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/driver.dart';
import '../../../core/services/driver_repository.dart';

/// 기사 목록 상태
class DriverListState {
  final List<Driver> drivers;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final DriverStatus? statusFilter;
  final String? searchQuery;
  final bool isLoading;
  final String? error;

  DriverListState({
    this.drivers = const [],
    this.page = 1,
    this.pageSize = 20,
    this.totalItems = 0,
    this.totalPages = 0,
    this.statusFilter,
    this.searchQuery,
    this.isLoading = false,
    this.error,
  });

  DriverListState copyWith({
    List<Driver>? drivers,
    int? page,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    DriverStatus? statusFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return DriverListState(
      drivers: drivers ?? this.drivers,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  DriverListState clearFilters() {
    return copyWith(
      statusFilter: null,
      searchQuery: null,
      page: 1,
    );
  }
}

/// 기사 목록 Notifier
class DriverListNotifier extends StateNotifier<DriverListState> {
  final DriverRepository _repository;

  DriverListNotifier(this._repository) : super(DriverListState()) {
    loadDrivers();
  }

  /// 기사 목록 로드
  Future<void> loadDrivers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getDrivers(
        page: state.page,
        limit: state.pageSize,
        status: state.statusFilter,
        search: state.searchQuery,
      );

      state = state.copyWith(
        drivers: result.drivers,
        page: result.page,
        totalItems: result.totalItems,
        totalPages: result.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 페이지 변경
  void setPage(int page) {
    state = state.copyWith(page: page);
    loadDrivers();
  }

  /// 상태 필터 설정
  void setStatusFilter(DriverStatus? status) {
    state = state.copyWith(statusFilter: status, page: 1);
    loadDrivers();
  }

  /// 검색어 설정
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query, page: 1);
    loadDrivers();
  }

  /// 필터 초기화
  void clearFilters() {
    state = state.clearFilters();
    loadDrivers();
  }

  /// 새로고침
  Future<void> refresh() async {
    state = state.copyWith(page: 1);
    await loadDrivers();
  }
}

/// 기사 목록 Provider
final driverListProvider = StateNotifierProvider<DriverListNotifier, DriverListState>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return DriverListNotifier(repository);
});

/// 개별 기사 상태
class DriverState {
  final Driver? data;
  final bool isLoading;
  final String? error;

  DriverState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  DriverState copyWith({
    Driver? data,
    bool? isLoading,
    String? error,
  }) {
    return DriverState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 개별 기사 Notifier
class DriverNotifier extends StateNotifier<DriverState> {
  final DriverRepository _repository;
  final String driverId;

  DriverNotifier(this._repository, this.driverId) : super(DriverState()) {
    loadDriver();
  }

  /// 기사 정보 로드
  Future<void> loadDriver() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final driver = await _repository.getDriverById(driverId);
      state = state.copyWith(
        data: driver,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadDriver();
  }
}

/// 개별 기사 Provider (Family)
final driverProvider = StateNotifierProvider.family<DriverNotifier, DriverState, String>(
  (ref, driverId) {
    final repository = ref.watch(driverRepositoryProvider);
    return DriverNotifier(repository, driverId);
  },
);

/// 기사 액션 (CRUD 작업)
class DriverActions {
  final DriverRepository _repository;
  final Ref _ref;

  DriverActions(this._repository, this._ref);

  /// 기사 생성
  Future<Driver> createDriver(CreateDriverDto dto) async {
    final driver = await _repository.createDriver(dto);
    // 목록 새로고침
    _ref.read(driverListProvider.notifier).refresh();
    return driver;
  }

  /// 기사 수정
  Future<Driver> updateDriver(String id, UpdateDriverDto dto) async {
    final driver = await _repository.updateDriver(id, dto);
    // 목록 새로고침
    _ref.read(driverListProvider.notifier).refresh();
    // 상세 화면도 새로고침 (있다면)
    _ref.invalidate(driverProvider(id));
    return driver;
  }

  /// 기사 삭제
  Future<void> deleteDriver(String id) async {
    await _repository.deleteDriver(id);
    // 목록 새로고침
    _ref.read(driverListProvider.notifier).refresh();
  }
}

/// 기사 액션 Provider
final driverActionsProvider = Provider<DriverActions>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return DriverActions(repository, ref);
});
