import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/route.dart';
import '../../../core/services/route_repository.dart';

/// 경로 목록 상태
class RouteListState {
  final List<RouteModel> routes;
  final List<RouteModel> filteredRoutes;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final RouteStatus? statusFilter;
  final String searchQuery;

  RouteListState({
    this.routes = const [],
    this.filteredRoutes = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.statusFilter,
    this.searchQuery = '',
  });

  RouteListState copyWith({
    List<RouteModel>? routes,
    List<RouteModel>? filteredRoutes,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    RouteStatus? statusFilter,
    String? searchQuery,
  }) {
    return RouteListState(
      routes: routes ?? this.routes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  RouteListState clearFilters() {
    return copyWith(
      statusFilter: null,
      searchQuery: '',
      filteredRoutes: routes,
    );
  }
}

/// 경로 목록 StateNotifier
class RouteListNotifier extends StateNotifier<RouteListState> {
  final RouteRepository _repository;

  RouteListNotifier(this._repository) : super(RouteListState()) {
    loadRoutes();
  }

  /// 경로 목록 로드
  Future<void> loadRoutes({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getRoutes(
        page: page,
        limit: 20,
        status: state.statusFilter,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      state = state.copyWith(
        routes: response.routes,
        filteredRoutes: response.routes,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalItems: response.totalItems,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 상태 필터 설정
  void setStatusFilter(RouteStatus? status) {
    state = state.copyWith(statusFilter: status);
    loadRoutes();
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadRoutes();
  }

  /// 필터 초기화
  void clearFilters() {
    state = state.clearFilters();
    loadRoutes();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadRoutes(page: 1);
  }

  /// 페이지 변경
  Future<void> changePage(int page) async {
    await loadRoutes(page: page);
  }
}

/// 경로 목록 Provider
final routeListProvider =
    StateNotifierProvider<RouteListNotifier, RouteListState>((ref) {
  final repository = ref.watch(routeRepositoryProvider);
  return RouteListNotifier(repository);
});

/// 개별 경로 상태
class RouteState {
  final RouteModel? data;
  final List<Stop>? stops;
  final bool isLoading;
  final String? error;

  RouteState({
    this.data,
    this.stops,
    this.isLoading = false,
    this.error,
  });

  RouteState copyWith({
    RouteModel? data,
    List<Stop>? stops,
    bool? isLoading,
    String? error,
  }) {
    return RouteState(
      data: data ?? this.data,
      stops: stops ?? this.stops,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 개별 경로 StateNotifier
class RouteNotifier extends StateNotifier<RouteState> {
  final RouteRepository _repository;
  final String routeId;

  RouteNotifier(this._repository, this.routeId) : super(RouteState()) {
    loadRoute();
  }

  /// 경로 상세 로드
  Future<void> loadRoute() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final route = await _repository.getRouteById(routeId);
      final stops = await _repository.getRouteStops(routeId);

      state = state.copyWith(
        data: route,
        stops: stops,
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
    await loadRoute();
  }
}

/// 개별 경로 Provider
final routeProvider =
    StateNotifierProvider.family<RouteNotifier, RouteState, String>(
  (ref, routeId) {
    final repository = ref.watch(routeRepositoryProvider);
    return RouteNotifier(repository, routeId);
  },
);

/// 경로 CRUD Actions
class RouteActions {
  final RouteRepository _repository;
  final Ref _ref;

  RouteActions(this._repository, this._ref);

  /// 경로 생성
  Future<RouteModel> createRoute(CreateRouteDto dto) async {
    final route = await _repository.createRoute(dto);
    // 목록 새로고침
    _ref.read(routeListProvider.notifier).refresh();
    return route;
  }

  /// 경로 수정
  Future<RouteModel> updateRoute(String id, UpdateRouteDto dto) async {
    final route = await _repository.updateRoute(id, dto);
    // 목록 새로고침
    _ref.read(routeListProvider.notifier).refresh();
    return route;
  }

  /// 경로 삭제
  Future<void> deleteRoute(String id) async {
    await _repository.deleteRoute(id);
    // 목록 새로고침
    _ref.read(routeListProvider.notifier).refresh();
  }

  /// 정류장 추가
  Future<Stop> addStop(String routeId, CreateStopDto dto) async {
    final stop = await _repository.addStop(routeId, dto);
    // 해당 경로 새로고침
    _ref.read(routeProvider(routeId).notifier).refresh();
    return stop;
  }

  /// 정류장 수정
  Future<Stop> updateStop(String routeId, String stopId, UpdateStopDto dto) async {
    final stop = await _repository.updateStop(routeId, stopId, dto);
    // 해당 경로 새로고침
    _ref.read(routeProvider(routeId).notifier).refresh();
    return stop;
  }

  /// 정류장 삭제
  Future<void> deleteStop(String routeId, String stopId) async {
    await _repository.deleteStop(routeId, stopId);
    // 해당 경로 새로고침
    _ref.read(routeProvider(routeId).notifier).refresh();
  }
}

/// 경로 Actions Provider
final routeActionsProvider = Provider<RouteActions>((ref) {
  final repository = ref.watch(routeRepositoryProvider);
  return RouteActions(repository, ref);
});
