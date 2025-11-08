import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/driver.dart';
import '../../../core/models/passenger.dart';
import '../../../core/models/route.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/vehicle.dart';

/// 기사 전용 운행 상세 화면
/// 노선, 정류장, 탑승자 목록 및 체크 기능
class DriverTripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;

  const DriverTripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<DriverTripDetailScreen> createState() =>
      _DriverTripDetailScreenState();
}

class _DriverTripDetailScreenState
    extends ConsumerState<DriverTripDetailScreen> {
  bool _isLoading = true;
  Trip? _trip;
  Vehicle? _vehicle;
  RouteModel? _route;
  List<Stop> _stops = [];
  Map<String, List<Passenger>> _passengersByStop = {};
  Map<String, TripPassenger> _tripPassengers = {};

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: API 연동 - 실제로는 백엔드에서 운행 상세 정보를 가져와야 함
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Mock 운행 정보
      final now = DateTime.now();
      _trip = Trip(
        id: widget.tripId,
        scheduleId: 'schedule-1',
        date: DateTime(now.year, now.month, now.day, 8, 0),
        vehicleId: 'vehicle-1',
        assignedDriverId: 'driver-1',
        status: TripStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
      );

      // Mock 차량 정보
      _vehicle = Vehicle(
        id: 'vehicle-1',
        plateNumber: '12가3456',
        model: '스타렉스',
        manufacturer: '현대',
        year: 2023,
        capacity: 11,
        color: '흰색',
        vehicleType: VehicleType.van,
        status: VehicleStatus.active,
        lastMaintenanceAt: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

      // Mock 경로 정보
      _route = RouteModel(
        id: 'route-1',
        name: '강남 A코스',
        description: '강남구 일대 등원 경로',
        status: RouteStatus.active,
        estimatedTime: 30, // 예상 소요 시간 30분
        totalDistance: 5000, // 5km
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        updatedAt: DateTime.now(),
      );

      // Mock 정류장 목록
      _stops = [
        Stop(
          id: 'stop-1',
          routeId: 'route-1',
          name: '테헤란로 입구',
          address: '서울시 강남구 테헤란로 123',
          latitude: 37.5665,
          longitude: 126.9780,
          order: 1,
          estimatedArrivalTime: 480, // 08:00 (분 단위)
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
        Stop(
          id: 'stop-2',
          routeId: 'route-1',
          name: '역삼역 2번 출구',
          address: '서울시 강남구 역삼동 456',
          latitude: 37.5000,
          longitude: 127.0360,
          order: 2,
          estimatedArrivalTime: 490, // 08:10
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
        Stop(
          id: 'stop-3',
          routeId: 'route-1',
          name: '삼성역 6번 출구',
          address: '서울시 강남구 삼성동 789',
          latitude: 37.5088,
          longitude: 127.0630,
          order: 3,
          estimatedArrivalTime: 500, // 08:20
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
        Stop(
          id: 'stop-dest',
          routeId: 'route-1',
          name: '행복어린이집',
          address: '서울시 강남구 학동로 100',
          latitude: 37.5150,
          longitude: 127.0200,
          order: 4,
          estimatedArrivalTime: 510, // 08:30
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          updatedAt: DateTime.now(),
        ),
      ];

      // Mock 정류장별 승객
      _passengersByStop = {
        'stop-1': [
          Passenger(
            id: 'passenger-1',
            name: '김철수',
            age: DateTime.now().year - 2015,
            gender: 'male',
            guardianName: '김부모',
            guardianPhone: '010-1111-2222',
            guardianRelation: '부',
            address: '서울시 강남구 테헤란로 123',
            emergencyContact: '010-3333-4444',
            emergencyRelation: '모',
            status: PassengerStatus.active,
            assignedRouteId: 'route-1',
            assignedStopId: 'stop-1',
            stopOrder: 1,
            createdAt: DateTime.now().subtract(const Duration(days: 180)),
            updatedAt: DateTime.now(),
          ),
        ],
        'stop-2': [
          Passenger(
            id: 'passenger-2',
            name: '이영희',
            age: DateTime.now().year - 2016,
            gender: 'female',
            guardianName: '이부모',
            guardianPhone: '010-2222-3333',
            guardianRelation: '모',
            address: '서울시 강남구 역삼동 456',
            emergencyContact: '010-4444-5555',
            emergencyRelation: '부',
            medicalNotes: '알레르기: 땅콩',
            status: PassengerStatus.active,
            assignedRouteId: 'route-1',
            assignedStopId: 'stop-2',
            stopOrder: 2,
            createdAt: DateTime.now().subtract(const Duration(days: 150)),
            updatedAt: DateTime.now(),
          ),
          Passenger(
            id: 'passenger-4',
            name: '최민지',
            age: DateTime.now().year - 2017,
            gender: 'female',
            guardianName: '최부모',
            guardianPhone: '010-4444-3333',
            guardianRelation: '모',
            address: '서울시 강남구 역삼동 500',
            emergencyContact: '010-5555-6666',
            emergencyRelation: '부',
            status: PassengerStatus.active,
            assignedRouteId: 'route-1',
            assignedStopId: 'stop-2',
            stopOrder: 2,
            createdAt: DateTime.now().subtract(const Duration(days: 120)),
            updatedAt: DateTime.now(),
          ),
        ],
        'stop-3': [
          Passenger(
            id: 'passenger-3',
            name: '박민수',
            age: DateTime.now().year - 2014,
            gender: 'male',
            guardianName: '박부모',
            guardianPhone: '010-5555-6666',
            guardianRelation: '부',
            address: '서울시 강남구 삼성동 789',
            emergencyContact: '010-7777-8888',
            emergencyRelation: '모',
            status: PassengerStatus.active,
            assignedRouteId: 'route-1',
            assignedStopId: 'stop-3',
            stopOrder: 3,
            createdAt: DateTime.now().subtract(const Duration(days: 200)),
            updatedAt: DateTime.now(),
          ),
        ],
      };

      // Mock 탑승 상태
      _tripPassengers = {
        'passenger-1': TripPassenger(
          id: 'tp-1',
          tripId: widget.tripId,
          passengerId: 'passenger-1',
          stopId: 'stop-1',
          isBoarded: false,
          isAlighted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        'passenger-2': TripPassenger(
          id: 'tp-2',
          tripId: widget.tripId,
          passengerId: 'passenger-2',
          stopId: 'stop-2',
          isBoarded: false,
          isAlighted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        'passenger-3': TripPassenger(
          id: 'tp-3',
          tripId: widget.tripId,
          passengerId: 'passenger-3',
          stopId: 'stop-3',
          isBoarded: false,
          isAlighted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        'passenger-4': TripPassenger(
          id: 'tp-4',
          tripId: widget.tripId,
          passengerId: 'passenger-4',
          stopId: 'stop-2',
          isBoarded: false,
          isAlighted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      };

      _isLoading = false;
    });
  }

  void _toggleBoarding(String passengerId, bool currentStatus) {
    setState(() {
      final tp = _tripPassengers[passengerId];
      if (tp != null) {
        _tripPassengers[passengerId] = TripPassenger(
          id: tp.id,
          tripId: tp.tripId,
          passengerId: tp.passengerId,
          stopId: tp.stopId,
          isBoarded: !currentStatus,
          isAlighted: tp.isAlighted,
          boardedAt: !currentStatus ? DateTime.now() : null,
          createdAt: tp.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });

    // TODO: API 호출하여 서버에 업데이트
  }

  void _startTrip() async {
    // TODO: API 호출 - 운행 시작
    setState(() {
      _trip = Trip(
        id: _trip!.id,
        scheduleId: _trip!.scheduleId,
        date: _trip!.date,
        vehicleId: _trip!.vehicleId,
        assignedDriverId: _trip!.assignedDriverId,
        status: TripStatus.inProgress,
        startedAt: DateTime.now(),
        createdAt: _trip!.createdAt,
        updatedAt: DateTime.now(),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운행을 시작했습니다')),
      );
    }
  }

  void _completeTrip() async {
    // TODO: API 호출 - 운행 완료
    setState(() {
      _trip = Trip(
        id: _trip!.id,
        scheduleId: _trip!.scheduleId,
        date: _trip!.date,
        vehicleId: _trip!.vehicleId,
        assignedDriverId: _trip!.assignedDriverId,
        status: TripStatus.completed,
        startedAt: _trip!.startedAt,
        completedAt: DateTime.now(),
        createdAt: _trip!.createdAt,
        updatedAt: DateTime.now(),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운행을 완료했습니다')),
      );

      // 홈으로 돌아가기
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  int _getStopPassengerCount(String stopId) {
    return _passengersByStop[stopId]?.length ?? 0;
  }

  int _getStopBoardedCount(String stopId) {
    final passengers = _passengersByStop[stopId] ?? [];
    return passengers.where((p) {
      final tp = _tripPassengers[p.id];
      return tp?.isBoarded == true;
    }).length;
  }

  String _formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final min = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_route?.name ?? '운행 상세'),
        actions: [
          if (_trip?.status == TripStatus.pending)
            TextButton.icon(
              onPressed: _startTrip,
              icon: const Icon(Icons.play_arrow),
              label: const Text('운행 시작'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            )
          else if (_trip?.status == TripStatus.inProgress)
            TextButton.icon(
              onPressed: _completeTrip,
              icon: const Icon(Icons.stop),
              label: const Text('운행 완료'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 운행 정보 헤더
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _vehicle?.plateNumber ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        _trip?.status == TripStatus.pending
                            ? '운행 대기'
                            : _trip?.status == TripStatus.inProgress
                                ? '운행 중'
                                : '완료',
                      ),
                      backgroundColor: _trip?.status == TripStatus.inProgress
                          ? Colors.green.shade100
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '출발 시간: ${_formatTime(_trip?.date.hour ?? 0 * 60 + (_trip?.date.minute ?? 0))}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // 정류장 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _stops.length,
              itemBuilder: (context, index) {
                final stop = _stops[index];
                final passengerCount = _getStopPassengerCount(stop.id);
                final boardedCount = _getStopBoardedCount(stop.id);
                final isDestination = index == _stops.length - 1;

                return _buildStopCard(
                  stop: stop,
                  passengerCount: passengerCount,
                  boardedCount: boardedCount,
                  isDestination: isDestination,
                  isLast: index == _stops.length - 1,
                  theme: theme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard({
    required Stop stop,
    required int passengerCount,
    required int boardedCount,
    required bool isDestination,
    required bool isLast,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Card(
          child: InkWell(
            onTap: isDestination
                ? null
                : () => _showPassengerList(stop),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 정류장 순서 아이콘
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDestination
                          ? theme.colorScheme.errorContainer
                          : theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isDestination
                          ? Icon(
                              Icons.flag,
                              color: theme.colorScheme.error,
                            )
                          : Text(
                              stop.order.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 정류장 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(stop.estimatedArrivalTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 승객 수
                  if (!isDestination) ...[
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: boardedCount == passengerCount
                                ? Colors.green.shade100
                                : theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$boardedCount/$passengerCount명',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: boardedCount == passengerCount
                                  ? Colors.green.shade900
                                  : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // 연결선
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 35),
            width: 2,
            height: 20,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }

  void _showPassengerList(Stop stop) {
    final passengers = _passengersByStop[stop.id] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // 헤더
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '탑승 예정 ${passengers.length}명',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // 승객 목록
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: passengers.length,
                      itemBuilder: (context, index) {
                        final passenger = passengers[index];
                        final tripPassenger = _tripPassengers[passenger.id];
                        final isBoarded = tripPassenger?.isBoarded == true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBoarded
                                  ? Colors.green.shade100
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              child: Text(
                                passenger.name[0],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBoarded
                                      ? Colors.green.shade900
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            title: Text(
                              passenger.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${passenger.age}세 · ${passenger.guardianName} (${passenger.guardianRelation})'),
                                if (passenger.medicalNotes != null)
                                  Text(
                                    passenger.medicalNotes!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: _trip?.status == TripStatus.inProgress
                                ? Checkbox(
                                    value: isBoarded,
                                    onChanged: (value) {
                                      setState(() {
                                        _toggleBoarding(passenger.id, isBoarded);
                                      });
                                      setModalState(() {});
                                    },
                                  )
                                : Icon(
                                    isBoarded
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isBoarded
                                        ? Colors.green
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
