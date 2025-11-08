import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/schedule.dart';
import '../providers/schedule_provider.dart';

/// 일정 상세 화면
class ScheduleDetailScreen extends ConsumerWidget {
  final String scheduleId;

  const ScheduleDetailScreen({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider(scheduleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 상세'),
        actions: [
          if (state.data != null) ...{
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Add schedule edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('일정 수정 기능은 추후 구현 예정입니다')),
                );
              },
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, ref),
              tooltip: '삭제',
            ),
          },
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ScheduleState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류 발생: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(scheduleProvider(scheduleId).notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('일정 정보를 찾을 수 없습니다'));
    }

    final schedule = state.data!;

    return RefreshIndicator(
      onRefresh: () => ref.read(scheduleProvider(scheduleId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, schedule),
            const SizedBox(height: 24),
            _buildBasicInfo(context, schedule),
            const SizedBox(height: 24),
            _buildOperationInfo(context, schedule),
            const SizedBox(height: 24),
            _buildValidityInfo(context, schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Schedule schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getTimeSlotColor(schedule.timeSlot).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTimeSlotIcon(schedule.timeSlot),
                size: 48,
                color: _getTimeSlotColor(schedule.timeSlot),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              schedule.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              schedule.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusBadge(context, schedule.status),
                const SizedBox(width: 12),
                _buildTimeSlotBadge(context, schedule.timeSlot),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, Schedule schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.access_time,
              label: '출발 시간',
              value: schedule.startTime,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.event_repeat,
              label: '운행 요일',
              value: _getDaysOfWeekLabel(schedule.daysOfWeek),
              iconColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationInfo(BuildContext context, Schedule schedule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운행 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.route,
              label: '경로',
              value: 'Route ${schedule.routeId.split('-').last}',
              iconColor: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.directions_car,
              label: '차량',
              value: 'Vehicle ${schedule.vehicleId.split('-').last}',
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: '기본 기사',
              value: 'Driver ${schedule.defaultDriverId.split('-').last}',
              iconColor: Colors.teal,
            ),
            if (schedule.defaultAttendantId != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.people,
                label: '동승자',
                value: 'Driver ${schedule.defaultAttendantId!.split('-').last}',
                iconColor: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidityInfo(BuildContext context, Schedule schedule) {
    final now = DateTime.now();
    final isValid = (schedule.validFrom == null || schedule.validFrom!.isBefore(now)) &&
                   (schedule.validTo == null || schedule.validTo!.isAfter(now));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '유효기간',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isValid ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValid ? Icons.check_circle : Icons.warning,
                        size: 16,
                        color: isValid ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isValid ? '유효' : '만료',
                        style: TextStyle(
                          color: isValid ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: '시작일',
              value: schedule.validFrom != null
                  ? _formatDate(schedule.validFrom!)
                  : '제한 없음',
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.event_busy,
              label: '종료일',
              value: schedule.validTo != null
                  ? _formatDate(schedule.validTo!)
                  : '제한 없음',
              iconColor: Colors.red,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.update,
              label: '마지막 업데이트',
              value: _formatDate(schedule.updatedAt),
              iconColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, ScheduleStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeSlotBadge(BuildContext context, TimeSlot timeSlot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTimeSlotColor(timeSlot).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimeSlotIcon(timeSlot),
            size: 16,
            color: _getTimeSlotColor(timeSlot),
          ),
          const SizedBox(width: 4),
          Text(
            _getTimeSlotLabel(timeSlot),
            style: TextStyle(
              color: _getTimeSlotColor(timeSlot),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(scheduleActionsProvider).deleteSchedule(scheduleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('일정이 삭제되었습니다')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
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

  String _getTimeSlotLabel(TimeSlot timeSlot) {
    switch (timeSlot) {
      case TimeSlot.morning:
        return '오전';
      case TimeSlot.afternoon:
        return '오후';
      case TimeSlot.evening:
        return '저녁';
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
      return '평일 (월~금)';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.contains(0) && daysOfWeek.contains(6)) {
      return '주말 (토~일)';
    }

    final dayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    return daysOfWeek.map((day) => dayLabels[day]).join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
