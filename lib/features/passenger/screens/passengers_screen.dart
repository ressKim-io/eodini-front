import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/passenger.dart';
import '../providers/passenger_provider.dart';

/// 탑승자 목록 화면
class PassengersScreen extends ConsumerStatefulWidget {
  const PassengersScreen({super.key});

  @override
  ConsumerState<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends ConsumerState<PassengersScreen> {
  final _searchController = TextEditingController();
  PassengerStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passengerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('탑승자 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/passengers/new'),
            tooltip: '탑승자 추가',
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터
          _buildSearchAndFilters(),

          // 탑승자 목록
          Expanded(
            child: _buildPassengerList(state),
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
              hintText: '이름, 보호자명, 연락처 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(passengerListProvider.notifier)
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
              ref.read(passengerListProvider.notifier).setSearch(
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
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStatus = null);
                      ref
                          .read(passengerListProvider.notifier)
                          .setStatusFilter(null);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ...PassengerStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getStatusLabel(status)),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? status : null);
                        ref
                            .read(passengerListProvider.notifier)
                            .setStatusFilter(selected ? status : null);
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

  /// 탑승자 목록 UI
  Widget _buildPassengerList(PassengerListState state) {
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
              onPressed: () => ref.read(passengerListProvider.notifier).refresh(),
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
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '등록된 탑승자가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.push('/passengers/new'),
              icon: const Icon(Icons.add),
              label: const Text('탑승자 추가하기'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(passengerListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.data!.items.length,
        itemBuilder: (context, index) {
          final passenger = state.data!.items[index];
          return _buildPassengerCard(passenger);
        },
      ),
    );
  }

  /// 탑승자 카드 UI
  Widget _buildPassengerCard(Passenger passenger) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/passengers/${passenger.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    _getStatusColor(passenger.status).withOpacity(0.1),
                child: Text(
                  passenger.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(passenger.status),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 탑승자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          passenger.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(passenger.status),
                        if (passenger.medicalNotes != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.medical_services,
                            size: 16,
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          passenger.age != null ? '${passenger.age}세' : '나이 미등록',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        if (passenger.gender != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            passenger.gender == '남' ? Icons.male : Icons.female,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            passenger.gender!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${passenger.guardianName} (${passenger.guardianPhone})',
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
  Widget _buildStatusChip(PassengerStatus status) {
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
  Widget _buildPagination(PassengerListState state) {
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
                ? () => ref.read(passengerListProvider.notifier).setPage(data.page - 1)
                : null,
          ),

          // 페이지 정보
          Text(
            '${data.page} / ${data.totalPages} (총 ${data.total}명)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // 다음 페이지
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: data.page < data.totalPages
                ? () => ref.read(passengerListProvider.notifier).setPage(data.page + 1)
                : null,
          ),
        ],
      ),
    );
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
