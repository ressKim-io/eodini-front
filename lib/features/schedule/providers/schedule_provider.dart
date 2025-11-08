import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/schedule.dart';
import '../../../core/services/schedule_repository.dart';

/// 일정 목록 상태
class ScheduleListState {
  final List<Schedule> schedules;
  final List<Schedule> filteredSchedules;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ScheduleStatus? statusFilter;
  final TimeSlot? timeSlotFilter;
  final String searchQuery;

  ScheduleListState({
    this.schedules = const [],
    this.filteredSchedules = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.statusFilter,
    this.timeSlotFilter,
    this.searchQuery = '',
  });

  ScheduleListState copyWith({
    List<Schedule>? schedules,
    List<Schedule>? filteredSchedules,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    ScheduleStatus? statusFilter,
    TimeSlot? timeSlotFilter,
    String? searchQuery,
  }) {
    return ScheduleListState(
      schedules: schedules ?? this.schedules,
      filteredSchedules: filteredSchedules ?? this.filteredSchedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      statusFilter: statusFilter ?? this.statusFilter,
      timeSlotFilter: timeSlotFilter ?? this.timeSlotFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  ScheduleListState clearFilters() {
    return copyWith(
      statusFilter: null,
      timeSlotFilter: null,
      searchQuery: '',
      filteredSchedules: schedules,
    );
  }
}

/// 일정 목록 StateNotifier
class ScheduleListNotifier extends StateNotifier<ScheduleListState> {
  final ScheduleRepository _repository;

  ScheduleListNotifier(this._repository) : super(ScheduleListState()) {
    loadSchedules();
  }

  /// 일정 목록 로드
  Future<void> loadSchedules({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getSchedules(
        page: page,
        limit: 20,
        status: state.statusFilter,
        timeSlot: state.timeSlotFilter,
      );

      // 클라이언트 사이드 검색 필터링
      var filteredSchedules = response.schedules;
      if (state.searchQuery.isNotEmpty) {
        filteredSchedules = response.schedules.where((schedule) {
          final query = state.searchQuery.toLowerCase();
          return schedule.name.toLowerCase().contains(query) ||
                 schedule.description.toLowerCase().contains(query);
        }).toList();
      }

      state = state.copyWith(
        schedules: response.schedules,
        filteredSchedules: filteredSchedules,
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
  void setStatusFilter(ScheduleStatus? status) {
    state = state.copyWith(statusFilter: status);
    loadSchedules();
  }

  /// 시간대 필터 설정
  void setTimeSlotFilter(TimeSlot? timeSlot) {
    state = state.copyWith(timeSlotFilter: timeSlot);
    loadSchedules();
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadSchedules();
  }

  /// 필터 초기화
  void clearFilters() {
    state = state.clearFilters();
    loadSchedules();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadSchedules(page: 1);
  }

  /// 페이지 변경
  Future<void> changePage(int page) async {
    await loadSchedules(page: page);
  }
}

/// 일정 목록 Provider
final scheduleListProvider =
    StateNotifierProvider<ScheduleListNotifier, ScheduleListState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleListNotifier(repository);
});

/// 개별 일정 상태
class ScheduleState {
  final Schedule? data;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    Schedule? data,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 개별 일정 StateNotifier
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;
  final String scheduleId;

  ScheduleNotifier(this._repository, this.scheduleId) : super(ScheduleState()) {
    loadSchedule();
  }

  /// 일정 상세 로드
  Future<void> loadSchedule() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final schedule = await _repository.getScheduleById(scheduleId);

      state = state.copyWith(
        data: schedule,
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
    await loadSchedule();
  }
}

/// 개별 일정 Provider
final scheduleProvider =
    StateNotifierProvider.family<ScheduleNotifier, ScheduleState, String>(
  (ref, scheduleId) {
    final repository = ref.watch(scheduleRepositoryProvider);
    return ScheduleNotifier(repository, scheduleId);
  },
);

/// 일정 CRUD Actions
class ScheduleActions {
  final ScheduleRepository _repository;
  final Ref _ref;

  ScheduleActions(this._repository, this._ref);

  /// 일정 생성
  Future<Schedule> createSchedule(CreateScheduleDto dto) async {
    final schedule = await _repository.createSchedule(dto);
    // 목록 새로고침
    _ref.read(scheduleListProvider.notifier).refresh();
    return schedule;
  }

  /// 일정 수정
  Future<Schedule> updateSchedule(String id, UpdateScheduleDto dto) async {
    final schedule = await _repository.updateSchedule(id, dto);
    // 목록 새로고침
    _ref.read(scheduleListProvider.notifier).refresh();
    return schedule;
  }

  /// 일정 삭제
  Future<void> deleteSchedule(String id) async {
    await _repository.deleteSchedule(id);
    // 목록 새로고침
    _ref.read(scheduleListProvider.notifier).refresh();
  }
}

/// 일정 Actions Provider
final scheduleActionsProvider = Provider<ScheduleActions>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleActions(repository, ref);
});
