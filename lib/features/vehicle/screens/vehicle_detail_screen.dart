import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/vehicle.dart';
import '../providers/vehicle_provider.dart';

/// 차량 상세 화면
class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('차량 상세'),
        actions: [
          if (state.data != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/vehicles/$vehicleId/edit'),
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

  Widget _buildBody(BuildContext context, WidgetRef ref, VehicleState state) {
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
              onPressed: () => ref.read(vehicleProvider(vehicleId).notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('차량 정보를 찾을 수 없습니다'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(vehicleProvider(vehicleId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleHeader(context, state.data!),
            const SizedBox(height: 24),
            _buildBasicInfo(context, state.data!),
            const SizedBox(height: 24),
            _buildMaintenanceInfo(context, state.data!),
            const SizedBox(height: 24),
            _buildDatesInfo(context, state.data!),
          ],
        ),
      ),
    );
  }

  /// 차량 헤더
  Widget _buildVehicleHeader(BuildContext context, Vehicle vehicle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getStatusColor(vehicle.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getVehicleIcon(vehicle.vehicleType),
                size: 48,
                color: _getStatusColor(vehicle.status),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vehicle.plateNumber,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context, vehicle.status),
          ],
        ),
      ),
    );
  }

  /// 기본 정보
  Widget _buildBasicInfo(BuildContext context, Vehicle vehicle) {
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
            _buildInfoRow(context, '차량 번호', vehicle.plateNumber),
            _buildInfoRow(context, '제조사', vehicle.manufacturer),
            _buildInfoRow(context, '모델명', vehicle.model),
            _buildInfoRow(context, '차량 타입', _getTypeLabel(vehicle.vehicleType)),
            _buildInfoRow(context, '연식', '${vehicle.year}년'),
            _buildInfoRow(context, '색상', vehicle.color),
            _buildInfoRow(context, '최대 승차 인원', '${vehicle.capacity}명'),
          ],
        ),
      ),
    );
  }

  /// 정비 및 보험 정보
  Widget _buildMaintenanceInfo(BuildContext context, Vehicle vehicle) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정비 및 보험 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              '보험 만료일',
              vehicle.insuranceExpiry != null
                  ? _formatDateWithDaysLeft(vehicle.insuranceExpiry!)
                  : '미등록',
              warning: _isExpiringSoon(vehicle.insuranceExpiry),
            ),
            _buildInfoRow(
              context,
              '검사 만료일',
              vehicle.inspectionExpiry != null
                  ? _formatDateWithDaysLeft(vehicle.inspectionExpiry!)
                  : '미등록',
              warning: _isExpiringSoon(vehicle.inspectionExpiry),
            ),
            _buildInfoRow(
              context,
              '최근 정비일',
              vehicle.lastMaintenanceAt != null
                  ? dateFormat.format(vehicle.lastMaintenanceAt!)
                  : '기록 없음',
            ),
          ],
        ),
      ),
    );
  }

  /// 시스템 정보
  Widget _buildDatesInfo(BuildContext context, Vehicle vehicle) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시스템 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(context, '차량 ID', vehicle.id),
            _buildInfoRow(context, '등록일', dateFormat.format(vehicle.createdAt)),
            _buildInfoRow(context, '최종 수정일', dateFormat.format(vehicle.updatedAt)),
            if (vehicle.deletedAt != null)
              _buildInfoRow(
                context,
                '삭제일',
                dateFormat.format(vehicle.deletedAt!),
              ),
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
            width: 120,
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
                      color: Colors.orange,
                    ),
                  ),
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: warning ? Colors.orange : null,
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
  Widget _buildStatusChip(BuildContext context, VehicleStatus status) {
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
        title: const Text('차량 삭제'),
        content: const Text('이 차량을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
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
        await ref.read(vehicleActionsProvider).deleteVehicle(vehicleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('차량이 삭제되었습니다')),
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

  String _getStatusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return '운행중';
      case VehicleStatus.maintenance:
        return '정비중';
      case VehicleStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return Colors.green;
      case VehicleStatus.maintenance:
        return Colors.orange;
      case VehicleStatus.inactive:
        return Colors.grey;
    }
  }

  String _getTypeLabel(VehicleType type) {
    switch (type) {
      case VehicleType.van:
        return '승합차';
      case VehicleType.bus:
        return '버스';
      case VehicleType.miniBus:
        return '소형버스';
      case VehicleType.sedan:
        return '승용차';
    }
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.van:
      case VehicleType.miniBus:
        return Icons.airport_shuttle;
      case VehicleType.bus:
        return Icons.directions_bus;
      case VehicleType.sedan:
        return Icons.directions_car;
    }
  }

  String _formatDateWithDaysLeft(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    if (difference < 0) {
      return '$dateStr (${difference.abs()}일 경과)';
    } else if (difference == 0) {
      return '$dateStr (오늘 만료)';
    } else {
      return '$dateStr (${difference}일 남음)';
    }
  }

  bool _isExpiringSoon(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference <= 30; // 30일 이내 만료
  }
}
