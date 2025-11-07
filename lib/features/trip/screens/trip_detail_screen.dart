import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/trip.dart';
import '../providers/trip_provider.dart';

/// 운행 상세 화면
class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('운행 상세'),
        actions: [
          if (state.data != null) ...[
            _buildActionButton(context, ref, state.data!),
          ],
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, Trip trip) {
    switch (trip.status) {
      case TripStatus.pending:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => _showStartDialog(context, ref, trip),
          tooltip: '운행 시작',
        );
      case TripStatus.inProgress:
        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'complete') {
              _showCompleteDialog(context, ref, trip);
            } else if (value == 'cancel') {
              _showCancelDialog(context, ref, trip);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('운행 완료'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text('운행 취소'),
                ],
              ),
            ),
          ],
        );
      case TripStatus.completed:
      case TripStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, TripState state) {
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
              onPressed: () => ref.read(tripProvider(tripId).notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('운행 정보를 찾을 수 없습니다'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tripProvider(tripId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state.data!),
            const SizedBox(height: 24),
            _buildBasicInfo(context, state.data!),
            const SizedBox(height: 24),
            _buildTimeInfo(context, state.data!),
            if (state.data!.tripPassengers != null &&
                state.data!.tripPassengers!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildPassengerList(context, ref, state.data!),
            ],
          ],
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(trip.status),
              size: 48,
              color: _getStatusColor(trip.status),
            ),
            const SizedBox(height: 12),
            Text(
              dateFormat.format(trip.date),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context, trip.status),
          ],
        ),
      ),
    );
  }

  /// 기본 정보
  Widget _buildBasicInfo(BuildContext context, Trip trip) {
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
              '운행 ID',
              trip.id,
            ),
            _buildInfoRow(
              context,
              '차량',
              trip.vehicleId.replaceAll('vehicle-', '번 차량'),
            ),
            _buildInfoRow(
              context,
              '기사',
              trip.assignedDriverId.replaceAll('driver-', '기사'),
            ),
            if (trip.assignedAttendantId != null)
              _buildInfoRow(
                context,
                '동승자',
                trip.assignedAttendantId!.replaceAll('attendant-', '동승자'),
              ),
            if (trip.notes != null)
              _buildInfoRow(
                context,
                '메모',
                trip.notes!,
              ),
          ],
        ),
      ),
    );
  }

  /// 시간 정보
  Widget _buildTimeInfo(BuildContext context, Trip trip) {
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운행 시간',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            if (trip.startedAt != null)
              _buildInfoRow(
                context,
                '시작 시간',
                dateTimeFormat.format(trip.startedAt!),
              ),
            if (trip.completedAt != null)
              _buildInfoRow(
                context,
                '종료 시간',
                dateTimeFormat.format(trip.completedAt!),
              ),
            if (trip.startedAt != null && trip.completedAt != null)
              _buildInfoRow(
                context,
                '소요 시간',
                _formatDuration(
                    trip.completedAt!.difference(trip.startedAt!)),
              ),
            if (trip.totalDistance != null)
              _buildInfoRow(
                context,
                '총 거리',
                '${(trip.totalDistance! / 1000).toStringAsFixed(1)} km',
              ),
            if (trip.cancelledAt != null) ...[
              _buildInfoRow(
                context,
                '취소 시간',
                dateTimeFormat.format(trip.cancelledAt!),
              ),
              if (trip.cancellationReason != null)
                _buildInfoRow(
                  context,
                  '취소 사유',
                  trip.cancellationReason!,
                  warning: true,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// 탑승자 목록
  Widget _buildPassengerList(BuildContext context, WidgetRef ref, Trip trip) {
    final passengers = trip.tripPassengers!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '탑승자 목록',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '총 ${passengers.length}명',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...passengers.map((passenger) {
              return _buildPassengerItem(context, ref, trip, passenger);
            }),
          ],
        ),
      ),
    );
  }

  /// 탑승자 항목
  Widget _buildPassengerItem(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
    TripPassenger passenger,
  ) {
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                passenger.isBoarded ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            child: Icon(
              passenger.isBoarded ? Icons.check : Icons.person,
              size: 20,
              color: passenger.isBoarded ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger.passengerId.replaceAll('passenger-', '탑승자 '),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (passenger.boardedAt != null)
                      Text(
                        '탑승: ${timeFormat.format(passenger.boardedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    if (passenger.boardedAt != null && passenger.alightedAt != null)
                      const SizedBox(width: 12),
                    if (passenger.alightedAt != null)
                      Text(
                        '하차: ${timeFormat.format(passenger.alightedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 탑승/하차 버튼 (운행 중일 때만)
          if (trip.status == TripStatus.inProgress) ...[
            if (!passenger.isBoarded)
              IconButton(
                icon: const Icon(Icons.login, color: Colors.green),
                onPressed: () => _boardPassenger(context, ref, trip.id, passenger.passengerId),
                tooltip: '탑승',
              )
            else if (!passenger.isAlighted)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.blue),
                onPressed: () => _alightPassenger(context, ref, trip.id, passenger.passengerId),
                tooltip: '하차',
              ),
          ],
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool warning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: warning ? Colors.red : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(BuildContext context, TripStatus status) {
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

  // ========== 액션 다이얼로그 ==========

  /// 운행 시작 다이얼로그
  Future<void> _showStartDialog(
      BuildContext context, WidgetRef ref, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운행 시작'),
        content: const Text('운행을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('시작'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(tripActionsProvider).startTrip(
              trip.id,
              const StartTripDto(startedBy: 'current-user'),
            );
        if (context.mounted) {
          ref.read(tripProvider(tripId).notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('운행이 시작되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('운행 시작 실패: $e')),
          );
        }
      }
    }
  }

  /// 운행 완료 다이얼로그
  Future<void> _showCompleteDialog(
      BuildContext context, WidgetRef ref, Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운행 완료'),
        content: const Text('운행을 완료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('완료'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(tripActionsProvider).completeTrip(
              trip.id,
              const CompleteTripDto(),
            );
        if (context.mounted) {
          ref.read(tripProvider(tripId).notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('운행이 완료되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('운행 완료 실패: $e')),
          );
        }
      }
    }
  }

  /// 운행 취소 다이얼로그
  Future<void> _showCancelDialog(
      BuildContext context, WidgetRef ref, Trip trip) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운행 취소'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '취소 사유',
            hintText: '예: 차량 고장',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('취소 사유를 입력해주세요')),
        );
        return;
      }

      try {
        await ref.read(tripActionsProvider).cancelTrip(
              trip.id,
              CancelTripDto(reason: reason),
            );
        if (context.mounted) {
          ref.read(tripProvider(tripId).notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('운행이 취소되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('운행 취소 실패: $e')),
          );
        }
      }
    }
  }

  /// 탑승 체크
  Future<void> _boardPassenger(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    String passengerId,
  ) async {
    try {
      await ref.read(tripActionsProvider).boardPassenger(tripId, passengerId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탑승 처리되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탑승 처리 실패: $e')),
        );
      }
    }
  }

  /// 하차 체크
  Future<void> _alightPassenger(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    String passengerId,
  ) async {
    try {
      await ref.read(tripActionsProvider).alightPassenger(tripId, passengerId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('하차 처리되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('하차 처리 실패: $e')),
        );
      }
    }
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

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return Icons.schedule;
      case TripStatus.inProgress:
        return Icons.directions_bus;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }
}
