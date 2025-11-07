import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/route.dart';
import '../../../core/models/vehicle.dart';
import '../providers/map_provider.dart';

/// 실시간 지도 화면
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _showVehicles = true;
  bool _showRoutes = true;
  bool _showStops = true;

  // 서울 중심 좌표 (기본 위치)
  static const LatLng _seoulCenter = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final theme = Theme.of(context);

    // 마커 및 폴리라인 업데이트
    _updateMapElements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 위치 추적'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mapProvider.notifier).refresh(),
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
            tooltip: '현재 위치',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _seoulCenter,
              zoom: 11.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) {
              // 마커 외부 탭 시 선택 해제
              ref.read(mapProvider.notifier).clearSelectedVehicle();
              ref.read(mapProvider.notifier).clearSelectedRoute();
            },
          ),

          // 로딩 인디케이터
          if (mapState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // 에러 표시
          if (mapState.error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mapState.error!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        onPressed: () {
                          // 에러 상태 클리어는 새로고침으로만 가능
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 필터 버튼
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildFilterButton(
                  icon: Icons.directions_car,
                  label: '차량',
                  isActive: _showVehicles,
                  onTap: () {
                    setState(() {
                      _showVehicles = !_showVehicles;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterButton(
                  icon: Icons.route,
                  label: '경로',
                  isActive: _showRoutes,
                  onTap: () {
                    setState(() {
                      _showRoutes = !_showRoutes;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildFilterButton(
                  icon: Icons.place,
                  label: '정류장',
                  isActive: _showStops,
                  onTap: () {
                    setState(() {
                      _showStops = !_showStops;
                    });
                  },
                ),
              ],
            ),
          ),

          // 하단 정보 패널
          if (mapState.selectedVehicleId != null ||
              mapState.selectedRouteId != null)
            _buildBottomSheet(),
        ],
      ),
    );
  }

  /// 지도 생성 콜백
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// 현재 위치로 이동
  void _moveToCurrentLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _seoulCenter,
          zoom: 11.0,
        ),
      ),
    );
  }

  /// 맵 요소 업데이트
  void _updateMapElements() {
    final mapState = ref.read(mapProvider);

    _markers.clear();
    _polylines.clear();

    // 차량 마커
    if (_showVehicles) {
      for (final vehicleInfo in mapState.vehicles.values) {
        if (vehicleInfo.location != null) {
          _markers.add(_createVehicleMarker(vehicleInfo));
        }
      }
    }

    // 경로 폴리라인
    if (_showRoutes) {
      for (final route in mapState.routes) {
        if (route.status == RouteStatus.active) {
          final stops = mapState.routeStops[route.id];
          if (stops != null && stops.isNotEmpty) {
            _polylines.add(_createRoutePolyline(route, stops));
          }
        }
      }
    }

    // 정류장 마커
    if (_showStops) {
      for (final entry in mapState.routeStops.entries) {
        for (final stop in entry.value) {
          _markers.add(_createStopMarker(stop));
        }
      }
    }
  }

  /// 차량 마커 생성
  Marker _createVehicleMarker(VehicleMapInfo vehicleInfo) {
    final vehicle = vehicleInfo.vehicle;
    final location = vehicleInfo.location!;
    final isSelected = ref.read(mapProvider).selectedVehicleId == vehicle.id;

    return Marker(
      markerId: MarkerId('vehicle-${vehicle.id}'),
      position: LatLng(location.latitude, location.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _getVehicleMarkerColor(vehicle.status),
      ),
      rotation: location.heading ?? 0,
      infoWindow: InfoWindow(
        title: vehicle.plateNumber,
        snippet: '${_getStatusLabel(vehicle.status)} | ${location.speed?.toStringAsFixed(1) ?? '0'}km/h',
      ),
      onTap: () {
        ref.read(mapProvider.notifier).selectVehicle(vehicle.id);
      },
      alpha: isSelected ? 1.0 : 0.8,
    );
  }

  /// 경로 폴리라인 생성
  Polyline _createRoutePolyline(RouteModel route, List<Stop> stops) {
    final points = stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
    final isSelected = ref.read(mapProvider).selectedRouteId == route.id;

    return Polyline(
      polylineId: PolylineId('route-${route.id}'),
      points: points,
      color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.5),
      width: isSelected ? 5 : 3,
      onTap: () {
        ref.read(mapProvider.notifier).selectRoute(route.id);
      },
    );
  }

  /// 정류장 마커 생성
  Marker _createStopMarker(Stop stop) {
    return Marker(
      markerId: MarkerId('stop-${stop.id}'),
      position: LatLng(stop.latitude, stop.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: stop.name,
        snippet: '${stop.order}번째 정류장',
      ),
      alpha: 0.7,
    );
  }

  /// 필터 버튼 위젯
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 하단 정보 패널
  Widget _buildBottomSheet() {
    final mapState = ref.watch(mapProvider);
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);
    final theme = Theme.of(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 차량 정보
              if (selectedVehicle != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: _getStatusColor(selectedVehicle.vehicle.status),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVehicle.vehicle.plateNumber,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${selectedVehicle.vehicle.manufacturer} ${selectedVehicle.vehicle.model}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(selectedVehicle.vehicle.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusLabel(selectedVehicle.vehicle.status),
                        style: TextStyle(
                          color: _getStatusColor(selectedVehicle.vehicle.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedVehicle.location != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.speed,
                        label: '${selectedVehicle.location!.speed?.toStringAsFixed(1) ?? '0'} km/h',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        label: _formatTime(selectedVehicle.location!.timestamp),
                      ),
                    ],
                  ),
                ],
              ],

              // 경로 정보
              if (selectedRoute != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedRoute.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedRoute.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.timer,
                      label: '${selectedRoute.estimatedTime}분',
                    ),
                    const SizedBox(width: 8),
                    if (selectedRoute.totalDistance != null)
                      _buildInfoChip(
                        icon: Icons.straighten,
                        label: '${(selectedRoute.totalDistance! / 1000).toStringAsFixed(1)}km',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 칩 위젯
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ========== Helper Methods ==========

  double _getVehicleMarkerColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return BitmapDescriptor.hueGreen;
      case VehicleStatus.maintenance:
        return BitmapDescriptor.hueOrange;
      case VehicleStatus.inactive:
        return BitmapDescriptor.hueRed;
    }
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return Colors.green;
      case VehicleStatus.maintenance:
        return Colors.orange;
      case VehicleStatus.inactive:
        return Colors.red;
    }
  }

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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
