import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';
import '../models/vehicle.dart';

/// WebSocket 이벤트 타입
enum WebSocketEventType {
  locationUpdate,
  statusChange,
  tripStatusChange,
  unknown,
}

/// 차량 위치 업데이트 이벤트
class VehicleLocationUpdate {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed; // km/h
  final double? heading; // degrees (0-360)

  VehicleLocationUpdate({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  factory VehicleLocationUpdate.fromJson(Map<String, dynamic> json) {
    return VehicleLocationUpdate(
      vehicleId: json['vehicle_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
    };
  }
}

/// 차량 상태 변경 이벤트
class VehicleStatusChange {
  final String vehicleId;
  final VehicleStatus status;
  final DateTime timestamp;

  VehicleStatusChange({
    required this.vehicleId,
    required this.status,
    required this.timestamp,
  });

  factory VehicleStatusChange.fromJson(Map<String, dynamic> json) {
    return VehicleStatusChange(
      vehicleId: json['vehicle_id'] as String,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VehicleStatus.inactive,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// WebSocket 연결 상태
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket 서비스
class WebSocketService {
  final Logger _logger = Logger();

  WebSocketChannel? _channel;
  StreamController<VehicleLocationUpdate>? _locationController;
  StreamController<VehicleStatusChange>? _statusController;
  StreamController<WebSocketConnectionState>? _stateController;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  bool _isDisposed = false;
  String? _wsUrl;

  // 스트림 getter
  Stream<VehicleLocationUpdate> get locationStream => _locationController!.stream;
  Stream<VehicleStatusChange> get statusStream => _statusController!.stream;
  Stream<WebSocketConnectionState> get connectionStateStream => _stateController!.stream;

  WebSocketService() {
    _initializeControllers();
    _initializeWebSocket();
  }

  /// 컨트롤러 초기화
  void _initializeControllers() {
    _locationController = StreamController<VehicleLocationUpdate>.broadcast();
    _statusController = StreamController<VehicleStatusChange>.broadcast();
    _stateController = StreamController<WebSocketConnectionState>.broadcast();
  }

  /// WebSocket 초기화
  void _initializeWebSocket() {
    // WebSocket URL 생성
    String baseUrl = 'ws://localhost:8080';
    try {
      if (dotenv.isInitialized) {
        final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
        // HTTP URL을 WebSocket URL로 변환
        baseUrl = apiUrl
            .replaceAll('http://', 'ws://')
            .replaceAll('https://', 'wss://')
            .replaceAll('/api/v1', '');
      }
    } catch (e) {
      _logger.w('Failed to read dotenv, using default WebSocket URL');
    }

    _wsUrl = '$baseUrl/ws';
    _logger.i('WebSocket URL: $_wsUrl');

    // Mock 모드가 아닐 때만 연결
    if (!AppConstants.useMockApi) {
      connect();
    } else {
      _logger.i('WebSocket in mock mode - not connecting');
      _stateController?.add(WebSocketConnectionState.disconnected);
    }
  }

  /// WebSocket 연결
  void connect() {
    if (_isDisposed || _channel != null) return;

    try {
      _stateController?.add(WebSocketConnectionState.connecting);
      _logger.i('Connecting to WebSocket: $_wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl!));

      // 연결 성공
      _stateController?.add(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      _logger.i('WebSocket connected');

      // 하트비트 시작
      _startHeartbeat();

      // 메시지 수신 리스너
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      _stateController?.add(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// 메시지 처리
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final eventType = _parseEventType(data['event'] as String?);

      switch (eventType) {
        case WebSocketEventType.locationUpdate:
          final update = VehicleLocationUpdate.fromJson(data);
          _locationController?.add(update);
          _logger.d('Location update: ${update.vehicleId}');
          break;

        case WebSocketEventType.statusChange:
          final statusChange = VehicleStatusChange.fromJson(data);
          _statusController?.add(statusChange);
          _logger.d('Status change: ${statusChange.vehicleId} -> ${statusChange.status}');
          break;

        case WebSocketEventType.tripStatusChange:
          // TODO: 운행 상태 변경 처리
          _logger.d('Trip status change: $data');
          break;

        case WebSocketEventType.unknown:
          _logger.w('Unknown event type: ${data['event']}');
          break;
      }
    } catch (e) {
      _logger.e('Error parsing WebSocket message: $e');
    }
  }

  /// 에러 처리
  void _handleError(error) {
    _logger.e('WebSocket error: $error');
    _stateController?.add(WebSocketConnectionState.error);
    _scheduleReconnect();
  }

  /// 연결 종료 처리
  void _handleDisconnect() {
    _logger.w('WebSocket disconnected');
    _channel = null;
    _stopHeartbeat();

    if (!_isDisposed) {
      _stateController?.add(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// 재연결 스케줄링
  void _scheduleReconnect() {
    if (_isDisposed || _reconnectTimer != null) return;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      _stateController?.add(WebSocketConnectionState.reconnecting);

      _logger.i('Reconnecting in ${_reconnectDelay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

      _reconnectTimer = Timer(_reconnectDelay, () {
        _reconnectTimer = null;
        _channel?.sink.close();
        _channel = null;
        connect();
      });
    } else {
      _logger.e('Max reconnection attempts reached');
      _stateController?.add(WebSocketConnectionState.error);
    }
  }

  /// 하트비트 시작
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          _logger.e('Failed to send heartbeat: $e');
        }
      }
    });
  }

  /// 하트비트 중지
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 이벤트 타입 파싱
  WebSocketEventType _parseEventType(String? event) {
    if (event == null) return WebSocketEventType.unknown;

    switch (event) {
      case 'location_update':
        return WebSocketEventType.locationUpdate;
      case 'status_change':
        return WebSocketEventType.statusChange;
      case 'trip_status_change':
        return WebSocketEventType.tripStatusChange;
      default:
        return WebSocketEventType.unknown;
    }
  }

  /// 연결 종료
  void disconnect() {
    _logger.i('Disconnecting WebSocket');
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _stateController?.add(WebSocketConnectionState.disconnected);
  }

  /// 리소스 정리
  void dispose() {
    _isDisposed = true;
    disconnect();
    _locationController?.close();
    _statusController?.close();
    _stateController?.close();
    _locationController = null;
    _statusController = null;
    _stateController = null;
  }
}

/// WebSocket 서비스 Provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();

  // Provider가 dispose될 때 서비스도 정리
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// 차량 위치 스트림 Provider
final vehicleLocationStreamProvider = StreamProvider<VehicleLocationUpdate>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.locationStream;
});

/// 차량 상태 스트림 Provider
final vehicleStatusStreamProvider = StreamProvider<VehicleStatusChange>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.statusStream;
});

/// WebSocket 연결 상태 Provider
final webSocketConnectionStateProvider = StreamProvider<WebSocketConnectionState>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionStateStream;
});
