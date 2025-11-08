import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/trip.dart';
import '../providers/trip_provider.dart';

/// 운행 목록 화면
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  TripStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('운행 관리'),
      ),
      body: Column(
        children: [
          // 필터
          _buildFilters(),

          // 운행 목록
          Expanded(
            child: _buildTripList(state),
          ),

          // 페이지네이션
          if (state.data != null && state.data!.totalPages > 1)
            _buildPagination(state),
        ],
      ),
    );
  }

  /// 필터 UI
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('전체 상태'),
              selected: _selectedStatus == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStatus = null);
                  ref.read(tripListProvider.notifier).setStatusFilter(null);
                }
              },
            ),
            const SizedBox(width: 8),
            ...TripStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_getStatusLabel(status)),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() => _selectedStatus = selected ? status : null);
                    ref
                        .read(tripListProvider.notifier)
                        .setStatusFilter(selected ? status : null);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 운행 목록 UI
  Widget _buildTripList(TripListState state) {
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
              onPressed: () => ref.read(tripListProvider.notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null || state.data!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '운행 기록이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tripListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.data!.items.length,
        itemBuilder: (context, index) {
          final trip = state.data!.items[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  /// 운행 카드 UI
  Widget _buildTripCard(Trip trip) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 날짜 + 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(trip.date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  _buildStatusChip(trip.status),
                ],
              ),
              const SizedBox(height: 12),

              // 운행 정보
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.directions_car,
                      label: '차량',
                      value: trip.vehicleId.replaceAll('vehicle-', '번 차량'),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person,
                      label: '기사',
                      value: trip.assignedDriverId.replaceAll('driver-', ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 시간 정보
              if (trip.startedAt != null || trip.completedAt != null)
                Row(
                  children: [
                    if (trip.startedAt != null)
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.play_arrow,
                          label: '시작',
                          value: timeFormat.format(trip.startedAt!),
                        ),
                      ),
                    if (trip.completedAt != null)
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.stop,
                          label: '종료',
                          value: timeFormat.format(trip.completedAt!),
                        ),
                      ),
                  ],
                ),

              // 탑승자 정보
              if (trip.tripPassengers != null &&
                  trip.tripPassengers!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '탑승자 ${trip.tripPassengers!.length}명',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    if (trip.status == TripStatus.inProgress ||
                        trip.status == TripStatus.completed) ...[
                      const SizedBox(width: 16),
                      Text(
                        '탑승: ${trip.tripPassengers!.where((p) => p.isBoarded).length}명',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                    if (trip.status == TripStatus.completed) ...[
                      const SizedBox(width: 8),
                      Text(
                        '하차: ${trip.tripPassengers!.where((p) => p.isAlighted).length}명',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 항목
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(TripStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 페이지네이션 UI
  Widget _buildPagination(TripListState state) {
    final data = state.data!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 페이지
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: data.page > 1
                ? () =>
                    ref.read(tripListProvider.notifier).setPage(data.page - 1)
                : null,
          ),

          // 페이지 정보
          Text(
            '${data.page} / ${data.totalPages} (총 ${data.total}개)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // 다음 페이지
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: data.page < data.totalPages
                ? () =>
                    ref.read(tripListProvider.notifier).setPage(data.page + 1)
                : null,
          ),
        ],
      ),
    );
  }

  // ========== Helper Methods ==========

  String _getStatusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return '대기중';
      case TripStatus.inProgress:
        return '운행중';
      case TripStatus.completed:
        return '완료';
      case TripStatus.cancelled:
        return '취소';
    }
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return Colors.orange;
      case TripStatus.inProgress:
        return Colors.blue;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.grey;
    }
  }
}
