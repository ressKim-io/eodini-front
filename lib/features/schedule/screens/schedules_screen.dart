import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/schedule.dart';
import '../providers/schedule_provider.dart';

/// 일정 목록 화면
class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});

  @override
  ConsumerState<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends ConsumerState<SchedulesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(scheduleListProvider.notifier).refresh(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _buildBody(context, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add schedule creation screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('일정 추가 기능은 추후 구현 예정입니다')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '일정명 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(scheduleListProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          ref.read(scheduleListProvider.notifier).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilters() {
    final state = ref.watch(scheduleListProvider);
    final hasFilters = state.statusFilter != null || state.timeSlotFilter != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 상태 필터
          Row(
            children: [
              const Text('상태: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip(
                        context,
                        label: '전체',
                        isSelected: state.statusFilter == null,
                        onTap: () => ref.read(scheduleListProvider.notifier).setStatusFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '활성',
                        isSelected: state.statusFilter == ScheduleStatus.active,
                        onTap: () => ref.read(scheduleListProvider.notifier).setStatusFilter(ScheduleStatus.active),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '비활성',
                        isSelected: state.statusFilter == ScheduleStatus.inactive,
                        onTap: () => ref.read(scheduleListProvider.notifier).setStatusFilter(ScheduleStatus.inactive),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 시간대 필터
          Row(
            children: [
              const Text('시간대: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip(
                        context,
                        label: '전체',
                        isSelected: state.timeSlotFilter == null,
                        onTap: () => ref.read(scheduleListProvider.notifier).setTimeSlotFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '오전',
                        isSelected: state.timeSlotFilter == TimeSlot.morning,
                        onTap: () => ref.read(scheduleListProvider.notifier).setTimeSlotFilter(TimeSlot.morning),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '오후',
                        isSelected: state.timeSlotFilter == TimeSlot.afternoon,
                        onTap: () => ref.read(scheduleListProvider.notifier).setTimeSlotFilter(TimeSlot.afternoon),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '저녁',
                        isSelected: state.timeSlotFilter == TimeSlot.evening,
                        onTap: () => ref.read(scheduleListProvider.notifier).setTimeSlotFilter(TimeSlot.evening),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => ref.read(scheduleListProvider.notifier).clearFilters(),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('초기화'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }

  Widget _buildBody(BuildContext context, ScheduleListState state) {
    if (state.isLoading && state.schedules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류 발생: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(scheduleListProvider.notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.filteredSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty || state.statusFilter != null || state.timeSlotFilter != null
                  ? '검색 결과가 없습니다'
                  : '등록된 일정이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(scheduleListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredSchedules.length + 1,
        itemBuilder: (context, index) {
          if (index == state.filteredSchedules.length) {
            return _buildPagination(state);
          }

          final schedule = state.filteredSchedules[index];
          return _buildScheduleCard(context, schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Schedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/schedules/${schedule.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTimeSlotColor(schedule.timeSlot).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTimeSlotIcon(schedule.timeSlot),
                      color: _getTimeSlotColor(schedule.timeSlot),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(context, schedule.status),
                      const SizedBox(height: 4),
                      Text(
                        schedule.startTime,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getTimeSlotColor(schedule.timeSlot),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.event_repeat,
                    label: _getDaysOfWeekLabel(schedule.daysOfWeek),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    context,
                    icon: Icons.route,
                    label: 'Route ${schedule.routeId.split('-').last}',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    context,
                    icon: Icons.directions_car,
                    label: 'Vehicle ${schedule.vehicleId.split('-').last}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ScheduleStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildPagination(ScheduleListState state) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1
                ? () => ref.read(scheduleListProvider.notifier).changePage(state.currentPage - 1)
                : null,
          ),
          Text(
            '${state.currentPage} / ${state.totalPages}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => ref.read(scheduleListProvider.notifier).changePage(state.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return '활성';
      case ScheduleStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return Colors.green;
      case ScheduleStatus.inactive:
        return Colors.grey;
    }
  }

  IconData _getTimeSlotIcon(TimeSlot timeSlot) {
    switch (timeSlot) {
      case TimeSlot.morning:
        return Icons.wb_sunny;
      case TimeSlot.afternoon:
        return Icons.wb_cloudy;
      case TimeSlot.evening:
        return Icons.nights_stay;
    }
  }

  Color _getTimeSlotColor(TimeSlot timeSlot) {
    switch (timeSlot) {
      case TimeSlot.morning:
        return Colors.orange;
      case TimeSlot.afternoon:
        return Colors.blue;
      case TimeSlot.evening:
        return Colors.indigo;
    }
  }

  String _getDaysOfWeekLabel(List<int> daysOfWeek) {
    if (daysOfWeek.length == 7) return '매일';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(0) && !daysOfWeek.contains(6)) {
      return '평일';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(0) && daysOfWeek.contains(6)) {
      return '주말';
    }

    final dayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    return daysOfWeek.map((day) => dayLabels[day]).join(', ');
  }
}
