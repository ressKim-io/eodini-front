import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 회원 타입 선택 화면
class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목
              Text(
                '어떤 유형으로\n가입하시겠어요?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '가입 유형에 따라 필요한 정보가 달라집니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 보호자 회원가입 카드
              _UserTypeCard(
                icon: Icons.family_restroom,
                iconColor: Colors.blue,
                title: '보호자',
                subtitle: '자녀의 통학 차량을 관리합니다',
                description: '자녀 정보를 함께 등록합니다',
                onTap: () => context.push('/register/parent'),
              ),
              const SizedBox(height: 16),

              // 일반 회원 카드
              _UserTypeCard(
                icon: Icons.person,
                iconColor: Colors.green,
                title: '일반 회원',
                subtitle: '본인이 직접 차량을 이용합니다',
                description: '본인 정보만 등록합니다',
                onTap: () => context.push('/register/passenger'),
              ),
              const SizedBox(height: 16),

              // 운전자 카드
              _UserTypeCard(
                icon: Icons.drive_eta,
                iconColor: Colors.orange,
                title: '운전자',
                subtitle: '통학 차량을 운전합니다',
                description: '면허 정보를 함께 등록합니다',
                onTap: () => context.push('/register/driver'),
              ),
              const SizedBox(height: 32),

              // 로그인 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('로그인'),
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

/// 사용자 타입 선택 카드 위젯
class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),

              // 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // 화살표 아이콘
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
}
