import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/route.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/route_repository.dart';
import '../../../core/services/vehicle_repository.dart';
import '../../../core/services/websocket_service.dart';

/// 차량 위치 정보 (지도용)
class VehicleMapInfo {
  final Vehicle vehicle;
  final VehicleLocationUpdate? location;

  VehicleMapInfo({
    required this.vehicle,
    this.location,
  });

  VehicleMapInfo copyWith({
    Vehicle? vehicle,
    VehicleLocationUpdate? location,
  }) {
    return VehicleMapInfo(
      vehicle: vehicle ?? this.vehicle,
      location: location ?? this.location,
    );
  }
}

/// 지도 상태
class MapState {
  final Map<String, VehicleMapInfo> vehicles; // vehicleId -> VehicleMapInfo
  final List<RouteModel> routes;
  final Map<String, List<Stop>> routeStops; // routeId -> stops
  final String? selectedVehicleId;
  final String? selectedRouteId;
  final bool isLoading;
  final String? error;

  MapState({
    this.vehicles = const {},
    this.routes = const [],
    this.routeStops = const {},
    this.selectedVehicleId,
    this.selectedRouteId,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    Map<String, VehicleMapInfo>? vehicles,
    List<RouteModel>? routes,
    Map<String, List<Stop>>? routeStops,
    String? selectedVehicleId,
    String? selectedRouteId,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      vehicles: vehicles ?? this.vehicles,
      routes: routes ?? this.routes,
      routeStops: routeStops ?? this.routeStops,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  MapState clearSelectedVehicle() {
    return copyWith(selectedVehicleId: null, selectedRouteId: selectedRouteId);
  }

  MapState clearSelectedRoute() {
    return copyWith(selectedVehicleId: selectedVehicleId, selectedRouteId: null);
  }
}

/// 지도 StateNotifier
class MapNotifier extends StateNotifier<MapState> {
  final VehicleRepository _vehicleRepository;
  final RouteRepository _routeRepository;
  final LocationService _locationService;
  final LocationUpdateMode _updateMode;

  StreamSubscription<Map<String, VehicleLocationUpdate>>? _locationSubscription;

  MapNotifier(
    this._vehicleRepository,
    this._routeRepository,
    this._locationService,
    this._updateMode,
  ) : super(MapState()) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    await loadInitialData();
    _subscribeToLocationUpdates();
  }

  /// 초기 데이터 로드
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 차량과 경로 동시 로드
      final results = await Future.wait([
        _vehicleRepository.getVehicles(page: 1, limit: 100),
        _routeRepository.getRoutes(page: 1, limit: 100),
      ]);

      final vehiclesResponse = results[0] as PaginatedVehicles;
      final routesResponse = results[1] as PaginatedRoutes;

      // 차량 맵 생성
      final vehicleMap = <String, VehicleMapInfo>{};
      for (final vehicle in vehiclesResponse.vehicles) {
        vehicleMap[vehicle.id] = VehicleMapInfo(vehicle: vehicle);
      }

      // 각 경로의 정류장 로드
      final routeStopsMap = <String, List<Stop>>{};
      for (final route in routesResponse.routes) {
        if (route.status == RouteStatus.active) {
          final stops = await _routeRepository.getRouteStops(route.id);
          routeStopsMap[route.id] = stops;
        }
      }

      state = state.copyWith(
        vehicles: vehicleMap,
        routes: routesResponse.routes,
        routeStops: routeStopsMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '데이터 로드 실패: $e',
      );
    }
  }

  /// 위치 업데이트 구독 (Polling 방식)
  void _subscribeToLocationUpdates() {
    // Polling 시작
    _locationService.startPolling();

    // 위치 업데이트 스트림 구독
    _locationSubscription = _locationService.locationStream.listen(
      _handleLocationUpdates,
      onError: (error) {
        print('Location stream error: $error');
      },
    );
  }

  /// 위치 업데이트 처리 (일괄 업데이트)
  void _handleLocationUpdates(Map<String, VehicleLocationUpdate> locationMap) {
    final vehicles = Map<String, VehicleMapInfo>.from(state.vehicles);

    // 모든 차량의 위치를 한 번에 업데이트
    for (final entry in locationMap.entries) {
      final vehicleId = entry.key;
      final location = entry.value;

      if (vehicles.containsKey(vehicleId)) {
        vehicles[vehicleId] = vehicles[vehicleId]!.copyWith(
          location: location,
        );
      }
    }

    state = state.copyWith(vehicles: vehicles);
  }

  /// 차량 선택
  void selectVehicle(String? vehicleId) {
    state = state.copyWith(selectedVehicleId: vehicleId);
  }

  /// 경로 선택
  void selectRoute(String? routeId) {
    state = state.copyWith(selectedRouteId: routeId);
  }

  /// 차량 선택 해제
  void clearSelectedVehicle() {
    state = state.clearSelectedVehicle();
  }

  /// 경로 선택 해제
  void clearSelectedRoute() {
    state = state.clearSelectedRoute();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadInitialData();
  }

  /// Polling 간격 변경
  void setPollingInterval(int seconds) {
    _locationService.setPollingInterval(seconds);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.stopPolling();
    super.dispose();
  }
}

/// 지도 Provider
final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final vehicleRepository = ref.watch(vehicleRepositoryProvider);
  final routeRepository = ref.watch(routeRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  final updateMode = ref.watch(locationUpdateModeProvider);

  return MapNotifier(
    vehicleRepository,
    routeRepository,
    locationService,
    updateMode,
  );
});

/// 선택된 차량 정보 Provider
final selectedVehicleProvider = Provider<VehicleMapInfo?>((ref) {
  final mapState = ref.watch(mapProvider);
  final selectedId = mapState.selectedVehicleId;

  if (selectedId == null) return null;
  return mapState.vehicles[selectedId];
});

/// 선택된 경로 정보 Provider
final selectedRouteProvider = Provider<RouteModel?>((ref) {
  final mapState = ref.watch(mapProvider);
  final selectedId = mapState.selectedRouteId;

  if (selectedId == null) return null;
  return mapState.routes.firstWhere(
    (r) => r.id == selectedId,
    orElse: () => mapState.routes.first,
  );
});

/// 선택된 경로의 정류장 Provider
final selectedRouteStopsProvider = Provider<List<Stop>>((ref) {
  final mapState = ref.watch(mapProvider);
  final selectedId = mapState.selectedRouteId;

  if (selectedId == null) return [];
  return mapState.routeStops[selectedId] ?? [];
});

/// 운행 중인 차량만 필터링
final activeVehiclesProvider = Provider<List<VehicleMapInfo>>((ref) {
  final mapState = ref.watch(mapProvider);
  return mapState.vehicles.values
      .where((v) => v.vehicle.status == VehicleStatus.active)
      .toList();
});

/// 활성 경로만 필터링
final activeRoutesProvider = Provider<List<RouteModel>>((ref) {
  final mapState = ref.watch(mapProvider);
  return mapState.routes.where((r) => r.status == RouteStatus.active).toList();
});
