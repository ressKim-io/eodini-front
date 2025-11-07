import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/route.dart';
import '../providers/route_provider.dart';

/// 경로 목록 화면
class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('경로 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(routeListProvider.notifier).refresh(),
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
          // TODO: Add route creation screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('경로 추가 기능은 추후 구현 예정입니다')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('경로 추가'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '경로명 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(routeListProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          ref.read(routeListProvider.notifier).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilters() {
    final state = ref.watch(routeListProvider);
    final hasFilters = state.statusFilter != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
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
                        onTap: () => ref.read(routeListProvider.notifier).setStatusFilter(null),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '활성',
                        isSelected: state.statusFilter == RouteStatus.active,
                        onTap: () => ref.read(routeListProvider.notifier).setStatusFilter(RouteStatus.active),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        label: '비활성',
                        isSelected: state.statusFilter == RouteStatus.inactive,
                        onTap: () => ref.read(routeListProvider.notifier).setStatusFilter(RouteStatus.inactive),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => ref.read(routeListProvider.notifier).clearFilters(),
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

  Widget _buildBody(BuildContext context, RouteListState state) {
    if (state.isLoading && state.routes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류 발생: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(routeListProvider.notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.filteredRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty || state.statusFilter != null
                  ? '검색 결과가 없습니다'
                  : '등록된 경로가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(routeListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredRoutes.length + 1,
        itemBuilder: (context, index) {
          if (index == state.filteredRoutes.length) {
            return _buildPagination(state);
          }

          final route = state.filteredRoutes[index];
          return _buildRouteCard(context, route);
        },
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RouteModel route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/routes/${route.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(route.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route.description ?? '설명 없음',
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
                  _buildStatusBadge(context, route.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    icon: Icons.location_on,
                    label: '${route.stopCount}개 정류장',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    context,
                    icon: Icons.straighten,
                    label: '${route.distance.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    context,
                    icon: Icons.access_time,
                    label: '${route.estimatedDuration} 분',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, RouteStatus status) {
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
          fontSize: 12,
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
          size: 16,
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

  Widget _buildPagination(RouteListState state) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1
                ? () => ref.read(routeListProvider.notifier).changePage(state.currentPage - 1)
                : null,
          ),
          Text(
            '${state.currentPage} / ${state.totalPages}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => ref.read(routeListProvider.notifier).changePage(state.currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(RouteStatus status) {
    switch (status) {
      case RouteStatus.active:
        return '활성';
      case RouteStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(RouteStatus status) {
    switch (status) {
      case RouteStatus.active:
        return Colors.green;
      case RouteStatus.inactive:
        return Colors.grey;
    }
  }
}
