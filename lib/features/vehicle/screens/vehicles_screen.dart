import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/vehicle.dart';
import '../providers/vehicle_provider.dart';

/// 차량 목록 화면
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  final _searchController = TextEditingController();
  VehicleStatus? _selectedStatus;
  VehicleType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('차량 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vehicles/new'),
            tooltip: '차량 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터
          _buildSearchAndFilters(),

          // 차량 목록
          Expanded(
            child: _buildVehicleList(state),
          ),

          // 페이지네이션
          if (state.data != null && state.data!.totalPages > 1)
            _buildPagination(state),
        ],
      ),
    );
  }

  /// 검색 및 필터 UI
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // 검색창
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '차량번호, 모델명, 제조사 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(vehicleListProvider.notifier)
                            .setSearch(null);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onSubmitted: (value) {
              ref.read(vehicleListProvider.notifier).setSearch(
                    value.isEmpty ? null : value,
                  );
            },
          ),
          const SizedBox(height: 12),

          // 필터 칩
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 상태 필터
                ChoiceChip(
                  label: const Text('전체 상태'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStatus = null);
                      ref
                          .read(vehicleListProvider.notifier)
                          .setStatusFilter(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...VehicleStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? status : null);
                        ref
                            .read(vehicleListProvider.notifier)
                            .setStatusFilter(selected ? status : null);
                      },
                    ),
                  );
                }),

                const SizedBox(width: 16),
                const VerticalDivider(),
                const SizedBox(width: 16),

                // 차량 타입 필터
                ChoiceChip(
                  label: const Text('전체 타입'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = null);
                      ref
                          .read(vehicleListProvider.notifier)
                          .setTypeFilter(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...VehicleType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getTypeLabel(type)),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() => _selectedType = selected ? type : null);
                        ref
                            .read(vehicleListProvider.notifier)
                            .setTypeFilter(selected ? type : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 차량 목록 UI
  Widget _buildVehicleList(VehicleListState state) {
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
              onPressed: () => ref.read(vehicleListProvider.notifier).refresh(),
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
              Icons.directions_car_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 차량이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.push('/vehicles/new'),
              icon: const Icon(Icons.add),
              label: const Text('차량 추가하기'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(vehicleListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.data!.items.length,
        itemBuilder: (context, index) {
          final vehicle = state.data!.items[index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }

  /// 차량 카드 UI
  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/vehicles/${vehicle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 차량 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getStatusColor(vehicle.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.vehicleType),
                  size: 32,
                  color: _getStatusColor(vehicle.status),
                ),
              ),
              const SizedBox(width: 16),

              // 차량 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicle.plateNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(vehicle.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.manufacturer} ${vehicle.model} (${vehicle.year}년)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '최대 ${vehicle.capacity}명',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.palette,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.color,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태 칩
  Widget _buildStatusChip(VehicleStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
  Widget _buildPagination(VehicleListState state) {
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
                ? () => ref.read(vehicleListProvider.notifier).setPage(data.page - 1)
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
                ? () => ref.read(vehicleListProvider.notifier).setPage(data.page + 1)
                : null,
          ),
        ],
      ),
    );
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
}
