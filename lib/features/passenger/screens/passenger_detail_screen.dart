import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/passenger.dart';
import '../providers/passenger_provider.dart';

/// 탑승자 상세 화면
class PassengerDetailScreen extends ConsumerWidget {
  final String passengerId;

  const PassengerDetailScreen({
    super.key,
    required this.passengerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passengerProvider(passengerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('탑승자 상세'),
        actions: [
          if (state.data != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/passengers/$passengerId/edit'),
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, ref),
              tooltip: '삭제',
            ),
          ],
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, PassengerState state) {
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
              onPressed: () => ref.read(passengerProvider(passengerId).notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('탑승자 정보를 찾을 수 없습니다'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(passengerProvider(passengerId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPassengerHeader(context, state.data!),
            const SizedBox(height: 24),
            _buildBasicInfo(context, state.data!),
            const SizedBox(height: 24),
            _buildGuardianInfo(context, state.data!),
            if (state.data!.emergencyContact != null) ...[
              const SizedBox(height: 24),
              _buildEmergencyInfo(context, state.data!),
            ],
            if (state.data!.medicalNotes != null ||
                state.data!.notes != null) ...[
              const SizedBox(height: 24),
              _buildNotesInfo(context, state.data!),
            ],
          ],
        ),
      ),
    );
  }

  /// 탑승자 헤더
  Widget _buildPassengerHeader(BuildContext context, Passenger passenger) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  _getStatusColor(passenger.status).withOpacity(0.1),
              child: Text(
                passenger.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(passenger.status),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              passenger.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip(context, passenger.status),
                if (passenger.medicalNotes != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 14,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '의료 특이사항',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 정보
  Widget _buildBasicInfo(BuildContext context, Passenger passenger) {
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
            _buildInfoRow(context, '이름', passenger.name),
            if (passenger.age != null)
              _buildInfoRow(context, '나이', '${passenger.age}세'),
            if (passenger.gender != null)
              _buildInfoRow(context, '성별', passenger.gender!),
            if (passenger.address != null)
              _buildInfoRow(context, '주소', passenger.address!),
            _buildInfoRow(
              context,
              '배정 경로',
              'Route ${passenger.assignedRouteId.replaceAll('route-', '')}',
            ),
            _buildInfoRow(
              context,
              '배정 정류장',
              'Stop ${passenger.assignedStopId.replaceAll('stop-', '')} (${passenger.stopOrder}번째)',
            ),
          ],
        ),
      ),
    );
  }

  /// 보호자 정보
  Widget _buildGuardianInfo(BuildContext context, Passenger passenger) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.family_restroom,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '보호자 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, '이름', passenger.guardianName),
            _buildInfoRow(context, '연락처', passenger.guardianPhone),
            if (passenger.guardianEmail != null)
              _buildInfoRow(context, '이메일', passenger.guardianEmail!),
            if (passenger.guardianRelation != null)
              _buildInfoRow(context, '관계', passenger.guardianRelation!),
          ],
        ),
      ),
    );
  }

  /// 비상 연락처 정보
  Widget _buildEmergencyInfo(BuildContext context, Passenger passenger) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emergency,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  '비상 연락처',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, '연락처', passenger.emergencyContact!),
            if (passenger.emergencyRelation != null)
              _buildInfoRow(context, '관계', passenger.emergencyRelation!),
          ],
        ),
      ),
    );
  }

  /// 특이사항 및 메모
  Widget _buildNotesInfo(BuildContext context, Passenger passenger) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '특이사항 및 메모',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (passenger.medicalNotes != null) ...[
              _buildInfoRow(
                context,
                '의료 특이사항',
                passenger.medicalNotes!,
                warning: true,
              ),
              if (passenger.notes != null) const SizedBox(height: 12),
            ],
            if (passenger.notes != null)
              _buildInfoRow(context, '메모', passenger.notes!),
          ],
        ),
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
            child: Row(
              children: [
                if (warning)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Colors.red,
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
          ),
        ],
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(BuildContext context, PassengerStatus status) {
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

  /// 삭제 확인 다이얼로그
  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('탑승자 삭제'),
        content: const Text('이 탑승자를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(passengerActionsProvider).deletePassenger(passengerId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('탑승자가 삭제되었습니다')),
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

  // ========== Helper Methods ==========

  String _getStatusLabel(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.active:
        return '활동중';
      case PassengerStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.active:
        return Colors.green;
      case PassengerStatus.inactive:
        return Colors.grey;
    }
  }
}
