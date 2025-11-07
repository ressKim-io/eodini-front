import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/driver/screens/driver_detail_screen.dart';
import '../../features/driver/screens/driver_form_screen.dart';
import '../../features/driver/screens/drivers_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/passenger/screens/passenger_detail_screen.dart';
import '../../features/passenger/screens/passenger_form_screen.dart';
import '../../features/passenger/screens/passengers_screen.dart';
import '../../features/route/screens/route_detail_screen.dart';
import '../../features/route/screens/routes_screen.dart';
import '../../features/trip/screens/trip_detail_screen.dart';
import '../../features/trip/screens/trips_screen.dart';
import '../../features/vehicle/screens/vehicle_detail_screen.dart';
import '../../features/vehicle/screens/vehicle_form_screen.dart';
import '../../features/vehicle/screens/vehicles_screen.dart';

/// 라우터 Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      // 인증되지 않은 사용자가 로그인/회원가입 페이지가 아닌 곳에 접근하려고 하면 로그인 페이지로
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // 이미 인증된 사용자가 로그인 페이지에 접근하려고 하면 홈으로
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // 차량 관리
      GoRoute(
        path: '/vehicles',
        name: 'vehicles',
        builder: (context, state) => const VehiclesScreen(),
      ),
      GoRoute(
        path: '/vehicles/new',
        name: 'vehicle-new',
        builder: (context, state) => const VehicleFormScreen(),
      ),
      GoRoute(
        path: '/vehicles/:id',
        name: 'vehicle-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VehicleDetailScreen(vehicleId: id);
        },
      ),
      GoRoute(
        path: '/vehicles/:id/edit',
        name: 'vehicle-edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VehicleFormScreen(vehicleId: id);
        },
      ),
      // 탑승자 관리
      GoRoute(
        path: '/passengers',
        name: 'passengers',
        builder: (context, state) => const PassengersScreen(),
      ),
      GoRoute(
        path: '/passengers/new',
        name: 'passenger-new',
        builder: (context, state) => const PassengerFormScreen(),
      ),
      GoRoute(
        path: '/passengers/:id',
        name: 'passenger-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PassengerDetailScreen(passengerId: id);
        },
      ),
      GoRoute(
        path: '/passengers/:id/edit',
        name: 'passenger-edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PassengerFormScreen(passengerId: id);
        },
      ),
      // 운행 관리
      GoRoute(
        path: '/trips',
        name: 'trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: '/trips/:id',
        name: 'trip-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TripDetailScreen(tripId: id);
        },
      ),
      // 실시간 지도
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      // 기사 관리
      GoRoute(
        path: '/drivers',
        name: 'drivers',
        builder: (context, state) => const DriversScreen(),
      ),
      GoRoute(
        path: '/drivers/new',
        name: 'driver-new',
        builder: (context, state) => const DriverFormScreen(),
      ),
      GoRoute(
        path: '/drivers/:id',
        name: 'driver-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DriverDetailScreen(driverId: id);
        },
      ),
      GoRoute(
        path: '/drivers/:id/edit',
        name: 'driver-edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DriverFormScreen(driverId: id);
        },
      ),
      // 경로 관리
      GoRoute(
        path: '/routes',
        name: 'routes',
        builder: (context, state) => const RoutesScreen(),
      ),
      GoRoute(
        path: '/routes/:id',
        name: 'route-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RouteDetailScreen(routeId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});
