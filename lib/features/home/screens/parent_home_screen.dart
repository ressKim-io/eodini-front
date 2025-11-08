import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/passenger.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/models/driver.dart';

/// 보호자 홈 화면
/// 자녀의 운행 정보만 표시 (오늘 탈 차량, 기사, 실시간 위치)
class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  // TODO: 백엔드 API 연동 필요
  // Mock 데이터로 시뮬레이션
  late Passenger _child;
  Trip? _todayTrip;
  Vehicle? _assignedVehicle;
  Driver? _assignedDriver;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock: 자녀 정보
    _child = Passenger(
      id: 'child-001',
      name: '홍길동',
      age: 7,
      gender: 'male',
      status: PassengerStatus.active,
      assignedRouteId: 'route-001',
      assignedStopId: 'stop-001',
      stopOrder: 3,
      guardianName: '홍아빠',
      guardianPhone: '010-1234-5678',
      guardianEmail: 'parent@example.com',
      guardianRelation: '부',
      emergencyContact: '010-9876-5432',
      emergencyRelation: '모',
      address: '서울시 강남구 테헤란로 123',
      medicalNotes: '알레르기: 땅콩',
      notes: '조용한 성격',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    // Mock: 오늘의 운행
    _todayTrip = Trip(
      id: 'trip-today',
      scheduleId: 'schedule-001',
      date: DateTime.now(),
      status: TripStatus.inProgress,
      vehicleId: 'vehicle-001',
      assignedDriverId: 'driver-001',
      assignedAttendantId: 'attendant-001',
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      startedBy: 'driver:driver-001',
      actualStartLocation: Location(
        latitude: 37.5665,
        longitude: 126.9780,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      tripPassengers: [
        TripPassenger(
          id: 'tp-001',
          tripId: 'trip-today',
          passengerId: 'child-001',
          stopId: 'stop-001',
          isBoarded: false,
          isAlighted: false,
          boardedAt: null,
          alightedAt: null,
          boardedLocation: null,
          alightedLocation: null,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );

    // Mock: 배정된 차량
    _assignedVehicle = Vehicle(
      id: 'vehicle-001',
      plateNumber: '12가3456',
      model: '그랜드스타렉스',
      manufacturer: '현대',
      vehicleType: VehicleType.van,
      capacity: 12,
      year: 2023,
      color: '흰색',
      status: VehicleStatus.active,
      insuranceExpiry: DateTime.now().add(const Duration(days: 180)),
      inspectionExpiry: DateTime.now().add(const Duration(days: 90)),
      lastMaintenanceAt: DateTime.now().subtract(const Duration(days: 15)),
      notes: '',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    // Mock: 배정된 기사
    _assignedDriver = Driver(
      id: 'driver-001',
      name: '김기사',
      phone: '010-1111-2222',
      email: 'driver@example.com',
      status: DriverStatus.active,
      licenseNumber: '11-12-345678-90',
      licenseType: LicenseType.type1Regular,
      licenseExpiry: DateTime.now().add(const Duration(days: 730)),
      address: '서울시 용산구',
      hireDate: DateTime.now().subtract(const Duration(days: 730)),
      emergencyContact: '010-3333-4444',
      notes: '',
      createdAt: DateTime.now().subtract(const Duration(days: 730)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: 데이터 새로고침
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 환영 메시지
              _buildWelcomeCard(),
              const SizedBox(height: 16),

              // 자녀 정보 카드
              _buildChildInfoCard(),
              const SizedBox(height: 16),

              // 오늘의 운행 상태
              _buildTodayTripCard(),
              const SizedBox(height: 16),

              // 차량 및 기사 정보
              _buildVehicleAndDriverCard(),
              const SizedBox(height: 16),

              // 빠른 액션
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, ${_child.guardianName}님!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_child.name}의 통학 정보를 확인하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: 자녀 상세 정보로 이동
          context.push('/passengers/${_child.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                child: Text(
                  _child.name[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _child.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_child.age}세 • ${_child.gender == 'male' ? '남' : '여'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_child.medicalNotes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.medical_information_outlined,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _child.medicalNotes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTripCard() {
    if (_todayTrip == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                '오늘 예정된 운행이 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final tripPassenger = _todayTrip!.tripPassengers
        .firstWhere((tp) => tp.passengerId == _child.id);

    return Card(
      color: _getTripStatusColor(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTripStatusIcon(),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTripStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 탑승 상태
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(
                    icon: Icons.login,
                    label: '탑승',
                    value: tripPassenger.isBoarded ? '완료' : '대기',
                    isCompleted: tripPassenger.isBoarded,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  _buildStatusItem(
                    icon: Icons.logout,
                    label: '하차',
                    value: tripPassenger.isAlighted ? '완료' : '대기',
                    isCompleted: tripPassenger.isAlighted,
                  ),
                ],
              ),
            ),

            if (_todayTrip!.status == TripStatus.inProgress) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 실시간 위치 화면으로 이동
                  context.push('/map?vehicleId=${_assignedVehicle!.id}');
                },
                icon: const Icon(Icons.location_on),
                label: const Text('실시간 위치 보기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getTripStatusColor() {
    if (_todayTrip == null) return Colors.grey;

    switch (_todayTrip!.status) {
      case TripStatus.pending:
        return Colors.orange;
      case TripStatus.inProgress:
        return Colors.blue;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getTripStatusIcon() {
    if (_todayTrip == null) return Icons.event_busy;

    switch (_todayTrip!.status) {
      case TripStatus.pending:
        return Icons.schedule;
      case TripStatus.inProgress:
        return Icons.directions_bus;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getTripStatusText() {
    if (_todayTrip == null) return '운행 없음';

    switch (_todayTrip!.status) {
      case TripStatus.pending:
        return '운행 대기 중';
      case TripStatus.inProgress:
        return '운행 중';
      case TripStatus.completed:
        return '운행 완료';
      case TripStatus.cancelled:
        return '운행 취소됨';
    }
  }

  Widget _buildVehicleAndDriverCard() {
    if (_assignedVehicle == null || _assignedDriver == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '차량 및 기사 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // 차량 정보
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _assignedVehicle!.plateNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_assignedVehicle!.manufacturer} ${_assignedVehicle!.model}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // 기사 정보
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_assignedDriver!.name} 기사님',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _assignedDriver!.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () {
                    // TODO: 전화 걸기
                  },
                  color: Colors.green[700],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 메뉴',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.history,
                label: '운행 기록',
                onTap: () {
                  // TODO: 운행 기록 화면으로 이동
                  context.push('/trips');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.notifications_outlined,
                label: '알림 설정',
                onTap: () {
                  // TODO: 알림 설정 화면으로 이동
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
