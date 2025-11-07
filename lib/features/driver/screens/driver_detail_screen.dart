import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/driver.dart';
import '../providers/driver_provider.dart';

/// 기사 상세 화면
class DriverDetailScreen extends ConsumerWidget {
  final String driverId;

  const DriverDetailScreen({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProvider(driverId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('기사 상세'),
        actions: [
          if (state.data != null) ...{
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/drivers/$driverId/edit'),
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

  Widget _buildBody(BuildContext context, WidgetRef ref, DriverState state) {
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
              onPressed: () => ref.read(driverProvider(driverId).notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.data == null) {
      return const Center(child: Text('기사 정보를 찾을 수 없습니다'));
    }

    final driver = state.data!;
    final isLicenseExpired = driver.licenseExpiry.isBefore(DateTime.now());
    final isLicenseExpiringSoon = driver.licenseExpiry.difference(DateTime.now()).inDays <= 30 && !isLicenseExpired;

    return RefreshIndicator(
      onRefresh: () => ref.read(driverProvider(driverId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, driver),
            if (isLicenseExpired || isLicenseExpiringSoon) ...{
              const SizedBox(height: 16),
              _buildLicenseWarning(context, driver, isLicenseExpired),
            },
            const SizedBox(height: 24),
            _buildBasicInfo(context, driver),
            const SizedBox(height: 16),
            _buildLicenseInfo(context, driver),
            const SizedBox(height: 16),
            _buildContactInfo(context, driver),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Driver driver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getStatusColor(driver.status).withOpacity(0.1),
              child: Text(
                driver.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(driver.status),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              driver.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(context, driver.status),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseWarning(BuildContext context, Driver driver, bool isExpired) {
    return Card(
      color: (isExpired ? Colors.red : Colors.orange).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: isExpired ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isExpired
                    ? '면허가 만료되었습니다. 즉시 갱신이 필요합니다.'
                    : '면허 만료가 ${driver.licenseExpiry.difference(DateTime.now()).inDays}일 남았습니다.',
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, Driver driver) {
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
            _buildInfoRow(context, '전화번호', driver.phone),
            if (driver.email != null) _buildInfoRow(context, '이메일', driver.email!),
            if (driver.address != null) _buildInfoRow(context, '주소', driver.address!),
            _buildInfoRow(context, '입사일', _formatDate(driver.hireDate)),
            if (driver.terminationDate != null)
              _buildInfoRow(context, '퇴사일', _formatDate(driver.terminationDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfo(BuildContext context, Driver driver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '면허 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, '면허번호', driver.licenseNumber),
            _buildInfoRow(context, '면허종류', _getLicenseTypeLabel(driver.licenseType)),
            _buildInfoRow(context, '만료일', _formatDate(driver.licenseExpiry)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, Driver driver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '비상 연락처',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              '비상 연락처',
              driver.emergencyContact ?? '미등록',
            ),
            if (driver.notes != null) _buildInfoRow(context, '메모', driver.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, DriverStatus status) {
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

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기사 삭제'),
        content: const Text('이 기사를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
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
        await ref.read(driverActionsProvider).deleteDriver(driverId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기사가 삭제되었습니다')),
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

  String _getStatusLabel(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return '활동중';
      case DriverStatus.onLeave:
        return '휴가중';
      case DriverStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return Colors.green;
      case DriverStatus.onLeave:
        return Colors.orange;
      case DriverStatus.inactive:
        return Colors.grey;
    }
  }

  String _getLicenseTypeLabel(LicenseType type) {
    switch (type) {
      case LicenseType.type1Regular:
        return '1종 보통';
      case LicenseType.type1Large:
        return '1종 대형';
      case LicenseType.type2Regular:
        return '2종 보통';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
