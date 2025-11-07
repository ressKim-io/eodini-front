import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/passenger.dart';
import '../providers/passenger_provider.dart';

/// 탑승자 추가/수정 화면
class PassengerFormScreen extends ConsumerStatefulWidget {
  final String? passengerId; // null이면 추가, 값이 있으면 수정

  const PassengerFormScreen({
    super.key,
    this.passengerId,
  });

  @override
  ConsumerState<PassengerFormScreen> createState() =>
      _PassengerFormScreenState();
}

class _PassengerFormScreenState extends ConsumerState<PassengerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 기본 정보
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;

  // 보호자 정보
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianRelationController = TextEditingController();

  // 비상 연락처
  final _emergencyContactController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  // 주소 및 특이사항
  final _addressController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _notesController = TextEditingController();

  // 상태 (수정 모드)
  PassengerStatus _selectedStatus = PassengerStatus.active;

  bool _isLoading = false;
  bool _isEditMode = false;
  Passenger? _existingPassenger;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.passengerId != null;
    if (_isEditMode) {
      _loadExistingPassenger();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _guardianRelationController.dispose();
    _emergencyContactController.dispose();
    _emergencyRelationController.dispose();
    _addressController.dispose();
    _medicalNotesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 기존 탑승자 정보 로드
  Future<void> _loadExistingPassenger() async {
    final state = ref.read(passengerProvider(widget.passengerId!));
    if (state.data != null) {
      _populateForm(state.data!);
    }
  }

  /// 폼에 기존 데이터 채우기
  void _populateForm(Passenger passenger) {
    _existingPassenger = passenger;
    _nameController.text = passenger.name;
    if (passenger.age != null) _ageController.text = passenger.age.toString();
    _selectedGender = passenger.gender;
    _guardianNameController.text = passenger.guardianName;
    _guardianPhoneController.text = passenger.guardianPhone;
    if (passenger.guardianEmail != null) {
      _guardianEmailController.text = passenger.guardianEmail!;
    }
    if (passenger.guardianRelation != null) {
      _guardianRelationController.text = passenger.guardianRelation!;
    }
    if (passenger.emergencyContact != null) {
      _emergencyContactController.text = passenger.emergencyContact!;
    }
    if (passenger.emergencyRelation != null) {
      _emergencyRelationController.text = passenger.emergencyRelation!;
    }
    if (passenger.address != null) _addressController.text = passenger.address!;
    if (passenger.medicalNotes != null) {
      _medicalNotesController.text = passenger.medicalNotes!;
    }
    if (passenger.notes != null) _notesController.text = passenger.notes!;
    _selectedStatus = passenger.status;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 수정 모드일 때 탑승자 데이터 감시
    if (_isEditMode && _existingPassenger == null) {
      ref.listen(passengerProvider(widget.passengerId!), (previous, next) {
        if (next.data != null && _existingPassenger == null) {
          _populateForm(next.data!);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '탑승자 수정' : '탑승자 추가'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 기본 정보
            _buildSectionTitle('기본 정보'),
            const SizedBox(height: 12),
            _buildNameField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildAgeField()),
                const SizedBox(width: 16),
                Expanded(child: _buildGenderDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressField(),
            const SizedBox(height: 24),

            // 보호자 정보
            _buildSectionTitle('보호자 정보'),
            const SizedBox(height: 12),
            _buildGuardianNameField(),
            const SizedBox(height: 16),
            _buildGuardianPhoneField(),
            const SizedBox(height: 16),
            _buildGuardianEmailField(),
            const SizedBox(height: 16),
            _buildGuardianRelationField(),
            const SizedBox(height: 24),

            // 비상 연락처
            _buildSectionTitle('비상 연락처 (선택)'),
            const SizedBox(height: 12),
            _buildEmergencyContactField(),
            const SizedBox(height: 16),
            _buildEmergencyRelationField(),
            const SizedBox(height: 24),

            // 특이사항
            _buildSectionTitle('특이사항 및 메모'),
            const SizedBox(height: 12),
            _buildMedicalNotesField(),
            const SizedBox(height: 16),
            _buildNotesField(),

            // 상태 (수정 모드에서만)
            if (_isEditMode) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('상태'),
              const SizedBox(height: 12),
              _buildStatusDropdown(),
            ],

            // 저장 버튼
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // 기본 정보 필드들
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '이름',
        hintText: '예: 김철수',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      decoration: const InputDecoration(
        labelText: '나이 (선택)',
        hintText: '예: 10',
        border: OutlineInputBorder(),
        suffixText: '세',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: '성별 (선택)',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: '남', child: Text('남')),
        DropdownMenuItem(value: '여', child: Text('여')),
      ],
      onChanged: (value) {
        setState(() => _selectedGender = value);
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        labelText: '주소 (선택)',
        hintText: '예: 서울시 강남구 역삼동 123-45',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.home),
      ),
      maxLines: 2,
    );
  }

  // 보호자 정보 필드들
  Widget _buildGuardianNameField() {
    return TextFormField(
      controller: _guardianNameController,
      decoration: const InputDecoration(
        labelText: '보호자 이름',
        hintText: '예: 김부모',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.family_restroom),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '보호자 이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildGuardianPhoneField() {
    return TextFormField(
      controller: _guardianPhoneController,
      decoration: const InputDecoration(
        labelText: '보호자 연락처',
        hintText: '예: 010-1234-5678',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '보호자 연락처를 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildGuardianEmailField() {
    return TextFormField(
      controller: _guardianEmailController,
      decoration: const InputDecoration(
        labelText: '보호자 이메일 (선택)',
        hintText: '예: parent@example.com',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildGuardianRelationField() {
    return TextFormField(
      controller: _guardianRelationController,
      decoration: const InputDecoration(
        labelText: '보호자 관계 (선택)',
        hintText: '예: 아버지, 어머니',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
      ),
    );
  }

  // 비상 연락처 필드들
  Widget _buildEmergencyContactField() {
    return TextFormField(
      controller: _emergencyContactController,
      decoration: const InputDecoration(
        labelText: '비상 연락처',
        hintText: '예: 010-9876-5432',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.emergency),
      ),
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildEmergencyRelationField() {
    return TextFormField(
      controller: _emergencyRelationController,
      decoration: const InputDecoration(
        labelText: '비상 연락처 관계',
        hintText: '예: 할머니',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }

  // 특이사항 필드들
  Widget _buildMedicalNotesField() {
    return TextFormField(
      controller: _medicalNotesController,
      decoration: const InputDecoration(
        labelText: '의료 특이사항 (선택)',
        hintText: '예: 알레르기: 땅콩',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medical_services, color: Colors.red),
      ),
      maxLines: 3,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: '메모 (선택)',
        hintText: '예: 학원 후 하차 - 목요일 제외',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  // 상태 드롭다운
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<PassengerStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: '상태',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info),
      ),
      items: PassengerStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 8),
              Text(_getStatusLabel(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  // 저장 버튼
  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _submitForm,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_isEditMode ? '수정 완료' : '탑승자 추가'),
    );
  }

  /// 폼 제출
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        // 수정
        final dto = UpdatePassengerDto(
          name: _nameController.text,
          age: _ageController.text.isNotEmpty
              ? int.tryParse(_ageController.text)
              : null,
          gender: _selectedGender,
          status: _selectedStatus,
          guardianName: _guardianNameController.text,
          guardianPhone: _guardianPhoneController.text,
          guardianEmail: _guardianEmailController.text.isNotEmpty
              ? _guardianEmailController.text
              : null,
          guardianRelation: _guardianRelationController.text.isNotEmpty
              ? _guardianRelationController.text
              : null,
          emergencyContact: _emergencyContactController.text.isNotEmpty
              ? _emergencyContactController.text
              : null,
          emergencyRelation: _emergencyRelationController.text.isNotEmpty
              ? _emergencyRelationController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          medicalNotes: _medicalNotesController.text.isNotEmpty
              ? _medicalNotesController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );

        await ref
            .read(passengerActionsProvider)
            .updatePassenger(widget.passengerId!, dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('탑승자 정보가 수정되었습니다')),
          );
          context.pop();
        }
      } else {
        // 추가
        final dto = CreatePassengerDto(
          name: _nameController.text,
          age: _ageController.text.isNotEmpty
              ? int.tryParse(_ageController.text)
              : null,
          gender: _selectedGender,
          guardianName: _guardianNameController.text,
          guardianPhone: _guardianPhoneController.text,
          guardianEmail: _guardianEmailController.text.isNotEmpty
              ? _guardianEmailController.text
              : null,
          guardianRelation: _guardianRelationController.text.isNotEmpty
              ? _guardianRelationController.text
              : null,
          emergencyContact: _emergencyContactController.text.isNotEmpty
              ? _emergencyContactController.text
              : null,
          emergencyRelation: _emergencyRelationController.text.isNotEmpty
              ? _emergencyRelationController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          medicalNotes: _medicalNotesController.text.isNotEmpty
              ? _medicalNotesController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
        );

        final passenger =
            await ref.read(passengerActionsProvider).createPassenger(dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('탑승자가 추가되었습니다')),
          );
          // 상세 화면으로 이동
          context.go('/passengers/${passenger.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ========== Helper Methods ==========

  String _getStatusLabel(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.active:
        return '활동중';
      case PassengerStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.active:
        return Colors.green;
      case PassengerStatus.inactive:
        return Colors.grey;
    }
  }
}
