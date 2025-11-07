import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import 'vehicle_repository.dart';
import 'websocket_service.dart';

/// 위치 업데이트 방식
enum LocationUpdateMode {
  polling, // HTTP Polling (권장: 10-30초 간격)
  websocket, // WebSocket (실시간, 1초 이하)
}

/// Polling 기반 위치 서비스
///
/// 10-30초 간격으로 HTTP API를 호출하여 차량 위치를 가져옵니다.
/// WebSocket보다 단순하고, 서버 리소스를 적게 사용합니다.
class LocationService {
  final VehicleRepository _vehicleRepository;
  final Logger _logger = Logger();

  Timer? _pollingTimer;
  StreamController<Map<String, VehicleLocationUpdate>>? _locationController;

  bool _isRunning = false;
  int _pollingInterval = AppConstants.locationUpdateInterval; // 기본 10초

  // 스트림 getter
  Stream<Map<String, VehicleLocationUpdate>> get locationStream =>
      _locationController!.stream;

  LocationService(this._vehicleRepository) {
    _locationController =
        StreamController<Map<String, VehicleLocationUpdate>>.broadcast();
  }

  /// Polling 시작
  void startPolling({int? intervalSeconds}) {
    if (_isRunning) {
      _logger.w('Polling already running');
      return;
    }

    _pollingInterval = intervalSeconds ?? AppConstants.locationUpdateInterval;
    _isRunning = true;

    _logger.i('Starting location polling (interval: ${_pollingInterval}s)');

    // 즉시 한 번 실행
    _fetchLocations();

    // 주기적 실행
    _pollingTimer = Timer.periodic(
      Duration(seconds: _pollingInterval),
      (_) => _fetchLocations(),
    );
  }

  /// Polling 중지
  void stopPolling() {
    if (!_isRunning) return;

    _logger.i('Stopping location polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isRunning = false;
  }

  /// 위치 데이터 가져오기
  Future<void> _fetchLocations() async {
    try {
      _logger.d('Fetching vehicle locations...');

      // 모든 차량 조회 (실제로는 active 차량만 조회하도록 최적화 가능)
      final response = await _vehicleRepository.getVehicles(
        page: 1,
        limit: 100,
        // status: VehicleStatus.active, // 운행중인 차량만
      );

      // Mock 데이터: 각 차량에 대해 랜덤 위치 생성
      final locationMap = <String, VehicleLocationUpdate>{};

      for (final vehicle in response.vehicles) {
        // TODO: 실제로는 별도의 API 엔드포인트에서 위치 데이터 가져오기
        // GET /vehicles/{id}/location 또는 GET /locations?vehicle_ids=...

        // Mock: 서울 중심 근처 랜덤 위치 생성
        final mockLocation = _generateMockLocation(vehicle.id);
        locationMap[vehicle.id] = mockLocation;
      }

      // 스트림에 전송
      _locationController?.add(locationMap);

      _logger.d('Updated ${locationMap.length} vehicle locations');
    } catch (e) {
      _logger.e('Failed to fetch locations: $e');
    }
  }

  /// Mock 위치 생성 (개발용)
  VehicleLocationUpdate _generateMockLocation(String vehicleId) {
    final random = vehicleId.hashCode % 100;

    // 서울 중심 좌표 (37.5665, 126.9780) 근처
    final lat = 37.5665 + (random / 1000.0) - 0.05;
    final lng = 126.9780 + ((random * 2) / 1000.0) - 0.1;

    return VehicleLocationUpdate(
      vehicleId: vehicleId,
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      speed: 30.0 + (random % 40).toDouble(), // 30-70 km/h
      heading: (random * 3.6) % 360, // 0-360도
    );
  }

  /// Polling 간격 변경
  void setPollingInterval(int seconds) {
    if (seconds < 5 || seconds > 60) {
      _logger.w('Invalid polling interval: $seconds (must be 5-60)');
      return;
    }

    _pollingInterval = seconds;
    _logger.i('Polling interval changed to ${_pollingInterval}s');

    // 실행 중이면 재시작
    if (_isRunning) {
      stopPolling();
      startPolling();
    }
  }

  /// 리소스 정리
  void dispose() {
    stopPolling();
    _locationController?.close();
    _locationController = null;
  }
}

/// 위치 서비스 Provider (Polling 방식)
final locationServiceProvider = Provider<LocationService>((ref) {
  final vehicleRepository = ref.watch(vehicleRepositoryProvider);
  final service = LocationService(vehicleRepository);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// 위치 스트림 Provider (Polling)
final locationStreamProvider =
    StreamProvider<Map<String, VehicleLocationUpdate>>((ref) {
  final service = ref.watch(locationServiceProvider);

  // Mock 모드가 아닐 때만 자동 시작
  if (!AppConstants.useMockApi) {
    service.startPolling();
  }

  return service.locationStream;
});

/// 현재 위치 업데이트 모드 설정
final locationUpdateModeProvider =
    StateProvider<LocationUpdateMode>((ref) => LocationUpdateMode.polling);
