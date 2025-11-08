import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import 'admin_home_screen.dart';
import 'driver_home_screen.dart';
import 'parent_home_screen.dart';
import 'passenger_home_screen.dart';

/// 역할 기반 홈 화면 라우터
/// 사용자의 역할에 따라 적절한 홈 화면을 표시합니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    // 사용자가 없으면 로딩 표시
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 역할에 따라 적절한 홈 화면 표시
    return switch (user.role) {
      UserRole.admin => const AdminHomeScreen(),
      UserRole.parent => const ParentHomeScreen(),
      UserRole.passenger => const PassengerHomeScreen(),
      UserRole.driver => const DriverHomeScreen(),
      UserRole.attendant => const AdminHomeScreen(), // TODO: 동승자 전용 화면 추가
    };
  }
}
