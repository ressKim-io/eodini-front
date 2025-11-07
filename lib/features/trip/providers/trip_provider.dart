import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/trip.dart';
import '../../../core/services/trip_repository.dart';

// ========== Repository Provider ==========

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripRepository(apiClient);
});

// ========== Trip List Provider ==========

/// 운행 목록 조회 파라미터
class TripListParams {
  final int page;
  final int limit;
  final TripStatus? status;
  final String? vehicleId;
  final String? driverId;
  final DateTime? startDate;
  final DateTime? endDate;

  TripListParams({
    this.page = 1,
    this.limit = 20,
    this.status,
    this.vehicleId,
    this.driverId,
    this.startDate,
    this.endDate,
  });

  TripListParams copyWith({
    int? page,
    int? limit,
    TripStatus? status,
    String? vehicleId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TripListParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripListParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          status == other.status &&
          vehicleId == other.vehicleId &&
          driverId == other.driverId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      status.hashCode ^
      vehicleId.hashCode ^
      driverId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}

/// 운행 목록 상태
class TripListState {
  final PaginatedTrips? data;
  final bool isLoading;
  final String? error;
  final TripListParams params;

  TripListState({
    this.data,
    this.isLoading = false,
    this.error,
    required this.params,
  });

  TripListState copyWith({
    PaginatedTrips? data,
    bool? isLoading,
    String? error,
    TripListParams? params,
  }) {
    return TripListState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      params: params ?? this.params,
    );
  }
}

/// 운행 목록 Provider
class TripListNotifier extends StateNotifier<TripListState> {
  final TripRepository _repository;

  TripListNotifier(this._repository)
      : super(TripListState(params: TripListParams())) {
    loadTrips();
  }

  /// 운행 목록 로드
  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getTrips(
        page: state.params.page,
        limit: state.params.limit,
        status: state.params.status,
        vehicleId: state.params.vehicleId,
        driverId: state.params.driverId,
        startDate: state.params.startDate,
        endDate: state.params.endDate,
      );

      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('운행 목록 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 상태 필터 변경
  void setStatusFilter(TripStatus? status) {
    state = state.copyWith(
      params: state.params.copyWith(status: status, page: 1),
    );
    loadTrips();
  }

  /// 차량 필터 변경
  void setVehicleFilter(String? vehicleId) {
    state = state.copyWith(
      params: state.params.copyWith(vehicleId: vehicleId, page: 1),
    );
    loadTrips();
  }

  /// 날짜 필터 변경
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      params: state.params.copyWith(
        startDate: startDate,
        endDate: endDate,
        page: 1,
      ),
    );
    loadTrips();
  }

  /// 페이지 변경
  void setPage(int page) {
    state = state.copyWith(
      params: state.params.copyWith(page: page),
    );
    loadTrips();
  }

  /// 필터 초기화
  void resetFilters() {
    state = TripListState(params: TripListParams());
    loadTrips();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadTrips();
  }
}

final tripListProvider =
    StateNotifierProvider<TripListNotifier, TripListState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListNotifier(repository);
});

// ========== Single Trip Provider ==========

/// 개별 운행 상태
class TripState {
  final Trip? data;
  final bool isLoading;
  final String? error;

  TripState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  TripState copyWith({
    Trip? data,
    bool? isLoading,
    String? error,
  }) {
    return TripState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 개별 운행 Provider
class TripNotifier extends StateNotifier<TripState> {
  final TripRepository _repository;
  final String tripId;

  TripNotifier(this._repository, this.tripId) : super(TripState()) {
    loadTrip();
  }

  /// 운행 상세 로드
  Future<void> loadTrip() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getTrip(tripId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('운행 상세 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadTrip();
  }
}

final tripProvider =
    StateNotifierProvider.family<TripNotifier, TripState, String>(
        (ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripNotifier(repository, tripId);
});

// ========== Trip Actions Provider ==========

/// 운행 액션
class TripActions {
  final TripRepository _repository;
  final Ref _ref;

  TripActions(this._repository, this._ref);

  /// 운행 시작
  Future<Trip> startTrip(String id, StartTripDto dto) async {
    final trip = await _repository.startTrip(id, dto);
    // 운행 목록 새로고침
    _ref.read(tripListProvider.notifier).refresh();
    return trip;
  }

  /// 운행 완료
  Future<Trip> completeTrip(String id, CompleteTripDto dto) async {
    final trip = await _repository.completeTrip(id, dto);
    // 운행 목록 새로고침
    _ref.read(tripListProvider.notifier).refresh();
    return trip;
  }

  /// 운행 취소
  Future<Trip> cancelTrip(String id, CancelTripDto dto) async {
    final trip = await _repository.cancelTrip(id, dto);
    // 운행 목록 새로고침
    _ref.read(tripListProvider.notifier).refresh();
    return trip;
  }

  /// 탑승자 탑승 체크
  Future<TripPassenger> boardPassenger(String tripId, String passengerId) async {
    final tripPassenger = await _repository.boardPassenger(tripId, passengerId);
    // 운행 상세 새로고침
    _ref.read(tripProvider(tripId).notifier).refresh();
    return tripPassenger;
  }

  /// 탑승자 하차 체크
  Future<TripPassenger> alightPassenger(
      String tripId, String passengerId) async {
    final tripPassenger =
        await _repository.alightPassenger(tripId, passengerId);
    // 운행 상세 새로고침
    _ref.read(tripProvider(tripId).notifier).refresh();
    return tripPassenger;
  }
}

final tripActionsProvider = Provider<TripActions>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripActions(repository, ref);
});
