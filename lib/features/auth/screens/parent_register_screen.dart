import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 보호자 회원가입 화면
class ParentRegisterScreen extends ConsumerStatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  ConsumerState<ParentRegisterScreen> createState() =>
      _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends ConsumerState<ParentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // 보호자 정보
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianAddressController = TextEditingController();

  // 아동 정보
  final _childNameController = TextEditingController();
  final _childBirthYearController = TextEditingController();
  String? _childGender;
  final _guardianRelationController = TextEditingController(text: '부모');
  final _emergencyContactController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  // 설정
  bool _isPublic = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianAddressController.dispose();
    _childNameController.dispose();
    _childBirthYearController.dispose();
    _guardianRelationController.dispose();
    _emergencyContactController.dispose();
    _emergencyRelationController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validatePage1()) return;
    if (_currentPage == 1 && !_validatePage2()) return;

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validatePage1() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _guardianNameController.text.isEmpty ||
        _guardianPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 정보를 모두 입력해주세요')),
      );
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
      );
      return false;
    }

    return true;
  }

  bool _validatePage2() {
    if (_childNameController.text.isEmpty ||
        _childBirthYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('자녀 정보를 모두 입력해주세요')),
      );
      return false;
    }

    final birthYear = int.tryParse(_childBirthYearController.text);
    if (birthYear == null || birthYear < 2000 || birthYear > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 출생년도를 입력해주세요')),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    // TODO: 보호자 회원가입 API 호출
    // final dto = ParentRegisterDto(
    //   email: _emailController.text,
    //   password: _passwordController.text,
    //   guardianName: _guardianNameController.text,
    //   guardianPhone: _guardianPhoneController.text,
    //   guardianAddress: _guardianAddressController.text.isEmpty ? null : _guardianAddressController.text,
    //   isPublic: _isPublic,
    //   childName: _childNameController.text,
    //   childBirthYear: int.parse(_childBirthYearController.text),
    //   childGender: _childGender,
    //   guardianRelation: _guardianRelationController.text,
    //   emergencyContact: _emergencyContactController.text.isEmpty ? null : _emergencyContactController.text,
    //   emergencyRelation: _emergencyRelationController.text.isEmpty ? null : _emergencyRelationController.text,
    //   medicalNotes: _medicalNotesController.text.isEmpty ? null : _medicalNotesController.text,
    // );

    // 임시: 성공 메시지
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다!')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage == 0 ? () => context.pop() : _previousPage,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 상태 표시
            _buildProgressIndicator(),

            // 페이지 뷰
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            // 하단 버튼
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildProgressStep(0, '보호자 정보'),
          ),
          Expanded(
            child: _buildProgressStep(1, '자녀 정보'),
          ),
          Expanded(
            child: _buildProgressStep(2, '설정'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentPage >= step;
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '보호자 본인 정보',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '보호자님의 정보를 입력해주세요',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // 이메일
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 이름
            TextField(
              controller: _guardianNameController,
              decoration: const InputDecoration(
                labelText: '이름',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 전화번호
            TextField(
              controller: _guardianPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010-1234-5678',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 주소 (선택)
            TextField(
              controller: _guardianAddressController,
              decoration: const InputDecoration(
                labelText: '주소 (선택)',
                prefixIcon: Icon(Icons.home_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '자녀 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '통학 차량을 이용할 자녀의 정보를 입력해주세요',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // 자녀 이름
          TextField(
            controller: _childNameController,
            decoration: const InputDecoration(
              labelText: '자녀 이름',
              prefixIcon: Icon(Icons.child_care),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 출생년도
          TextField(
            controller: _childBirthYearController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: '출생년도',
              hintText: '2018',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 성별
          DropdownButtonFormField<String>(
            value: _childGender,
            decoration: const InputDecoration(
              labelText: '성별',
              prefixIcon: Icon(Icons.wc),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('남자')),
              DropdownMenuItem(value: 'female', child: Text('여자')),
            ],
            onChanged: (value) {
              setState(() {
                _childGender = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 보호자 관계
          TextField(
            controller: _guardianRelationController,
            decoration: const InputDecoration(
              labelText: '보호자 관계',
              hintText: '부모, 조부모, 친척 등',
              prefixIcon: Icon(Icons.people_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 비상 연락처
          TextField(
            controller: _emergencyContactController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '비상 연락처 (선택)',
              hintText: '010-9876-5432',
              prefixIcon: Icon(Icons.emergency),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 비상 연락처 관계
          TextField(
            controller: _emergencyRelationController,
            decoration: const InputDecoration(
              labelText: '비상 연락처 관계 (선택)',
              hintText: '모, 할머니 등',
              prefixIcon: Icon(Icons.people_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // 의료 특이사항
          TextField(
            controller: _medicalNotesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '의료 특이사항 (선택)',
              hintText: '알레르기, 지병 등',
              prefixIcon: Icon(Icons.medical_information_outlined),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '개인정보 공개 설정',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 사용자에게 정보 공개 여부를 선택해주세요',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // 공개/비공개 선택
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    title: const Text('정보 공개'),
                    subtitle: Text(
                      _isPublic
                          ? '이름, 연락처가 다른 사용자에게 보입니다'
                          : '이름, 연락처가 관리자에게만 보입니다',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 공개 정보 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      '개인정보 공개 안내',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem('공개 시', '같은 경로의 보호자끼리 연락이 가능합니다'),
                _buildInfoItem('비공개 시', '관리자와 운전자만 정보를 확인할 수 있습니다'),
                const SizedBox(height: 8),
                Text(
                  '※ 이메일은 항상 비공개로 관리됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 약관 동의
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원가입 시 개인정보 수집 및 이용에 동의하는 것으로 간주합니다.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '• 수집 항목: 이름, 이메일, 전화번호, 주소, 자녀 정보',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  '• 이용 목적: 통학 차량 관리 서비스 제공',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  '• 보유 기간: 회원 탈퇴 시까지',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _currentPage == 2 ? '가입 완료' : '다음',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
