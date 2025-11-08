import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/passenger.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/vehicle.dart';
import '../../../core/models/driver.dart';
import '../../auth/providers/auth_provider.dart';

/// 일반 회원(성인 탑승자) 홈 화면
/// 본인의 운행 정보만 표시 (오늘 탈 차량, 기사, 실시간 위치)
class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  // TODO: 백엔드 API 연동 필요
  // Mock 데이터로 시뮬레이션
  late Passenger _me;
  Trip? _todayTrip;
  Vehicle? _assignedVehicle;
  Driver? _assignedDriver;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Mock: 본인 정보
    _me = Passenger(
      id: 'passenger-001',
      name: '김철수',
      age: 35,
      gender: 'male',
      status: PassengerStatus.active,
      assignedRouteId: 'route-001',
      assignedStopId: 'stop-002',
      stopOrder: 5,
      guardianName: '본인',
      guardianPhone: '010-5555-6666',
      guardianEmail: 'passenger@example.com',
      guardianRelation: '본인',
      emergencyContact: '010-7777-8888',
      emergencyRelation: '배우자',
      address: '서울시 서초구 서초대로 123',
      medicalNotes: null,
      notes: '',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    );

    // Mock: 오늘의 운행
    _todayTrip = Trip(
      id: 'trip-today-002',
      scheduleId: 'schedule-002',
      date: DateTime.now(),
      status: TripStatus.pending,
      vehicleId: 'vehicle-002',
      assignedDriverId: 'driver-002',
      assignedAttendantId: null,
      startedAt: null,
      startedBy: null,
      actualStartLocation: null,
      tripPassengers: [
        TripPassenger(
          id: 'tp-002',
          tripId: 'trip-today-002',
          passengerId: 'passenger-001',
          stopId: 'stop-002',
          isBoarded: false,
          isAlighted: false,
          boardedAt: null,
          alightedAt: null,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );

    // Mock: 배정된 차량
    _assignedVehicle = Vehicle(
      id: 'vehicle-002',
      plateNumber: '34나5678',
      model: '소나타',
      manufacturer: '현대',
      vehicleType: VehicleType.sedan,
      capacity: 4,
      year: 2024,
      color: '검정',
      status: VehicleStatus.active,
      insuranceExpiry: DateTime.now().add(const Duration(days: 200)),
      inspectionExpiry: DateTime.now().add(const Duration(days: 100)),
      lastMaintenanceAt: DateTime.now().subtract(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    );

    // Mock: 배정된 기사
    _assignedDriver = Driver(
      id: 'driver-002',
      name: '이운전',
      phone: '010-2222-3333',
      email: 'driver2@example.com',
      status: DriverStatus.active,
      licenseNumber: '22-34-567890-12',
      licenseType: LicenseType.type1Regular,
      licenseExpiry: DateTime.now().add(const Duration(days: 365)),
      address: '서울시 강남구',
      hireDate: DateTime.now().subtract(const Duration(days: 365)),
      emergencyContact: '010-4444-5555',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
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
            icon: const Icon(Icons.swap_horiz),
            tooltip: '역할 전환',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('역할 전환'),
                  content: const Text('다른 역할로 로그인하시겠습니까?\n현재 계정에서 로그아웃됩니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/welcome');
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
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

              // 오늘의 운행 상태
              _buildTodayTripCard(),
              const SizedBox(height: 16),

              // 차량 및 기사 정보
              _buildVehicleAndDriverCard(),
              const SizedBox(height: 16),

              // 본인 정보 카드
              _buildMyInfoCard(),
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
              '안녕하세요, ${_me.name}님!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '오늘의 운행 정보를 확인하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
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

    final tripPassenger =
        _todayTrip!.tripPassengers?.firstWhere((tp) => tp.passengerId == _me.id);

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
                    value: tripPassenger?.isBoarded == true ? '완료' : '대기',
                    isCompleted: tripPassenger?.isBoarded == true,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  _buildStatusItem(
                    icon: Icons.logout,
                    label: '하차',
                    value: tripPassenger?.isAlighted == true ? '완료' : '대기',
                    isCompleted: tripPassenger?.isAlighted == true,
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
                    Icons.directions_car,
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

  Widget _buildMyInfoCard() {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: 본인 상세 정보로 이동
          context.push('/passengers/${_me.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple[100],
                child: Text(
                  _me.name[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
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
                      _me.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _me.guardianPhone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_me.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _me.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
