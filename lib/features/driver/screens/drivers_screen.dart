import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/driver.dart';
import '../providers/driver_provider.dart';

/// 기사 목록 화면
class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기사 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/drivers/new'),
            tooltip: '기사 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 검색창
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '이름, 전화번호, 이메일 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(driverListProvider.notifier).setSearchQuery(null);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (value) {
                    ref.read(driverListProvider.notifier).setSearchQuery(
                          value.isEmpty ? null : value,
                        );
                  },
                ),
                const SizedBox(height: 12),

                // 상태 필터 칩
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('전체 상태'),
                        selected: state.statusFilter == null,
                        onSelected: (_) {
                          ref.read(driverListProvider.notifier).setStatusFilter(null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...DriverStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getStatusLabel(status)),
                            selected: state.statusFilter == status,
                            onSelected: (_) {
                              ref.read(driverListProvider.notifier).setStatusFilter(status);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 목록
          Expanded(
            child: _buildBody(context, state),
          ),

          // 페이지네이션
          if (state.totalPages > 1) _buildPagination(context, state),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DriverListState state) {
    if (state.isLoading && state.drivers.isEmpty) {
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
              onPressed: () => ref.read(driverListProvider.notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 기사가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.push('/drivers/new'),
              icon: const Icon(Icons.add),
              label: const Text('기사 추가'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(driverListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.drivers.length,
        itemBuilder: (context, index) {
          final driver = state.drivers[index];
          return _buildDriverCard(context, driver);
        },
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, Driver driver) {
    final theme = Theme.of(context);
    final isLicenseExpiringSoon = _isLicenseExpiringSoon(driver.licenseExpiry);
    final isLicenseExpired = driver.licenseExpiry.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/drivers/${driver.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 아바타
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _getStatusColor(driver.status).withOpacity(0.1),
                    child: Text(
                      driver.name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(driver.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 이름 및 상태
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              driver.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(driver.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          driver.phone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 면허 경고 아이콘
                  if (isLicenseExpired || isLicenseExpiringSoon)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isLicenseExpired ? Colors.red : Colors.orange)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber,
                        color: isLicenseExpired ? Colors.red : Colors.orange,
                        size: 24,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 추가 정보
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.badge_outlined,
                    label: _getLicenseTypeLabel(driver.licenseType),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: '면허 ${_formatDate(driver.licenseExpiry)}',
                    color: isLicenseExpired
                        ? Colors.red
                        : (isLicenseExpiringSoon ? Colors.orange : null),
                  ),
                ],
              ),

              // 면허 만료 경고 메시지
              if (isLicenseExpired || isLicenseExpiringSoon) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isLicenseExpired ? Colors.red : Colors.orange)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: isLicenseExpired ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLicenseExpired
                              ? '면허가 만료되었습니다'
                              : '면허 만료가 ${_getDaysUntil(driver.licenseExpiry)}일 남았습니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLicenseExpired ? Colors.red : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(DriverStatus status) {
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context, DriverListState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 버튼
          TextButton.icon(
            onPressed: state.page > 1
                ? () => ref.read(driverListProvider.notifier).setPage(state.page - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('이전'),
          ),

          // 페이지 정보
          Text(
            '${state.page} / ${state.totalPages} 페이지',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // 다음 버튼
          TextButton.icon(
            onPressed: state.page < state.totalPages
                ? () => ref.read(driverListProvider.notifier).setPage(state.page + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('다음'),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }

  // ========== Helper Methods ==========

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

  bool _isLicenseExpiringSoon(DateTime expiry) {
    final daysUntil = expiry.difference(DateTime.now()).inDays;
    return daysUntil > 0 && daysUntil <= 30;
  }

  int _getDaysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }
}
