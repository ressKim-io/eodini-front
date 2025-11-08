import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 최초 진입 시 역할 선택 화면
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 로고 및 타이틀
              Icon(
                Icons.directions_bus,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Eodini',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '실시간 통학/통근 차량 관리',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              Text(
                '이용자 유형을 선택해주세요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      icon: Icons.family_restroom,
                      title: '보호자',
                      subtitle: '자녀의 통학 차량을 관리하는 학부모',
                      color: Colors.blue,
                      onTap: () => context.push('/login', extra: 'parent'),
                    ),
                    const SizedBox(height: 16),

                    _RoleCard(
                      icon: Icons.person,
                      title: '일반 사용자',
                      subtitle: '통근/통학 차량을 이용하는 성인',
                      color: Colors.green,
                      onTap: () => context.push('/login', extra: 'passenger'),
                    ),
                    const SizedBox(height: 16),

                    _RoleCard(
                      icon: Icons.admin_panel_settings,
                      title: '관리자',
                      subtitle: '기관의 차량 및 운행을 관리하는 담당자',
                      color: Colors.orange,
                      onTap: () => context.push('/login', extra: 'admin'),
                    ),
                    const SizedBox(height: 16),

                    _RoleCard(
                      icon: Icons.local_shipping,
                      title: '운전자',
                      subtitle: '차량을 운전하고 탑승자를 관리하는 기사',
                      color: Colors.purple,
                      onTap: () => context.push('/login', extra: 'driver'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 역할 선택 카드
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
