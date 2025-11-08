import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/driver.dart';
import '../../../core/models/passenger.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/vehicle.dart';
import '../../auth/providers/auth_provider.dart';
import 'driver_trip_detail_screen.dart';

/// 운전자 전용 홈 화면
/// 오늘 배정된 운행과 탑승자 체크리스트를 보여줍니다.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  Driver? _driver;
  Vehicle? _assignedVehicle;
  List<Trip> _todayTrips = [];
  List<Passenger> _passengers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: API 연동 - 실제로는 백엔드에서 운전자 정보와 오늘 배정된 운행을 가져와야 함
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Mock 운전자 정보
      _driver = Driver(
        id: 'driver-1',
        name: '김기사',
        phone: '010-1234-5678',
        licenseNumber: '11-12-345678-90',
        licenseType: LicenseType.type1Regular,
        licenseExpiry: DateTime(2027, 12, 31),
        hireDate: DateTime.now().subtract(const Duration(days: 365)),
        status: DriverStatus.active,
        emergencyContact: '010-8765-4321',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

      // Mock 배정 차량
      _assignedVehicle = Vehicle(
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

      // Mock 오늘 배정된 운행 (오전, 오후)
      final now = DateTime.now();
      _todayTrips = [
        Trip(
          id: 'trip-morning',
          scheduleId: 'schedule-1',
          date: DateTime(now.year, now.month, now.day, 8, 0),
          vehicleId: 'vehicle-1',
          assignedDriverId: 'driver-1',
          status: TripStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
        ),
        Trip(
          id: 'trip-afternoon',
          scheduleId: 'schedule-1',
          date: DateTime(now.year, now.month, now.day, 15, 30),
          vehicleId: 'vehicle-1',
          assignedDriverId: 'driver-1',
          status: TripStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
        ),
      ];

      // Mock 탑승 예정 승객
      _passengers = [
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
      ];

      _isLoading = false;
    });
  }

  String _getTripTimeLabel(Trip trip) {
    final hour = trip.date.hour;
    if (hour < 12) return '등원';
    if (hour < 18) return '하원';
    return '야간';
  }

  Color _getTripStatusColor(TripStatus status, ThemeData theme) {
    switch (status) {
      case TripStatus.pending:
        return theme.colorScheme.primary;
      case TripStatus.inProgress:
        return Colors.green;
      case TripStatus.completed:
        return theme.colorScheme.outline;
      case TripStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  String _getTripStatusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return '예정';
      case TripStatus.inProgress:
        return '운행중';
      case TripStatus.completed:
        return '완료';
      case TripStatus.cancelled:
        return '취소';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).user;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eodini Driver'),
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
            icon: const Icon(Icons.notifications_outlined),
            tooltip: '알림',
            onPressed: () {
              // TODO: 알림 페이지로 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
            onPressed: () {
              // TODO: 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDriverData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              Text(
                '안녕하세요, ${user?.name ?? '기사'}님',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 안전운행 하세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // 배정 차량 정보
              if (_assignedVehicle != null) ...[
                Text(
                  '배정 차량',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.directions_bus,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _assignedVehicle!.plateNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_assignedVehicle!.manufacturer} ${_assignedVehicle!.model}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '정원 ${_assignedVehicle!.capacity}명',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 오늘의 운행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 운행',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_todayTrips.length}건',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_todayTrips.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '배정된 운행이 없습니다',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._todayTrips.map((trip) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DriverTripDetailScreen(
                              tripId: trip.id,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTripStatusColor(trip.status, theme)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getTripTimeLabel(trip),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _getTripStatusColor(trip.status, theme),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTripStatusColor(trip.status, theme)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getTripStatusLabel(trip.status),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _getTripStatusColor(trip.status, theme),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (trip.status == TripStatus.pending)
                                  FilledButton.tonal(
                                    onPressed: () {
                                      // TODO: 운행 시작
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('운행을 시작했습니다'),
                                        ),
                                      );
                                    },
                                    child: const Text('운행 시작'),
                                  )
                                else if (trip.status == TripStatus.inProgress)
                                  FilledButton(
                                    onPressed: () {
                                      // TODO: 운행 완료
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('운행을 완료했습니다'),
                                        ),
                                      );
                                    },
                                    child: const Text('운행 완료'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.route,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '강남 A코스', // TODO: 실제로는 Schedule에서 Route 정보를 가져와야 함
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${trip.date.hour.toString().padLeft(2, '0')}:${trip.date.minute.toString().padLeft(2, '0')} 출발',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // 탑승 예정 승객
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '탑승 예정 승객',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_passengers.length}명',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._passengers.map((passenger) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        passenger.name[0],
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      passenger.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${passenger.age}세 · ${passenger.guardianName} (${passenger.guardianRelation})'),
                        if (passenger.medicalNotes != null)
                          Text(
                            passenger.medicalNotes!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () {
                        // TODO: 보호자에게 전화 걸기
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${passenger.guardianPhone} 전화 걸기'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 빠른 작업
              Text(
                '빠른 작업',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickActionCard(
                    icon: Icons.history,
                    label: '운행 기록',
                    onTap: () {
                      context.push('/trips');
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.report_problem_outlined,
                    label: '문제 신고',
                    onTap: () {
                      // TODO: 문제 신고 페이지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('문제 신고 기능은 준비 중입니다')),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.build_outlined,
                    label: '차량 점검',
                    onTap: () {
                      // TODO: 차량 점검 체크리스트
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('차량 점검 기능은 준비 중입니다')),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.help_outline,
                    label: '도움말',
                    onTap: () {
                      // TODO: 도움말 페이지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('도움말 기능은 준비 중입니다')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 빠른 작업 카드 위젯
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
