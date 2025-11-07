import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/vehicle.dart';
import '../providers/vehicle_provider.dart';

/// 차량 추가/수정 화면
class VehicleFormScreen extends ConsumerStatefulWidget {
  final String? vehicleId; // null이면 추가, 값이 있으면 수정

  const VehicleFormScreen({
    super.key,
    this.vehicleId,
  });

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacityController = TextEditingController();

  VehicleType _selectedType = VehicleType.van;
  VehicleStatus _selectedStatus = VehicleStatus.active;
  DateTime? _insuranceExpiry;
  DateTime? _inspectionExpiry;

  bool _isLoading = false;
  bool _isEditMode = false;
  Vehicle? _existingVehicle;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.vehicleId != null;
    if (_isEditMode) {
      _loadExistingVehicle();
    }
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  /// 기존 차량 정보 로드
  Future<void> _loadExistingVehicle() async {
    final state = ref.read(vehicleProvider(widget.vehicleId!));
    if (state.data != null) {
      _populateForm(state.data!);
    }
  }

  /// 폼에 기존 데이터 채우기
  void _populateForm(Vehicle vehicle) {
    _existingVehicle = vehicle;
    _plateNumberController.text = vehicle.plateNumber;
    _manufacturerController.text = vehicle.manufacturer;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _colorController.text = vehicle.color;
    _capacityController.text = vehicle.capacity.toString();
    _selectedType = vehicle.vehicleType;
    _selectedStatus = vehicle.status;
    _insuranceExpiry = vehicle.insuranceExpiry;
    _inspectionExpiry = vehicle.inspectionExpiry;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 수정 모드일 때 차량 데이터 감시
    if (_isEditMode && _existingVehicle == null) {
      ref.listen(vehicleProvider(widget.vehicleId!), (previous, next) {
        if (next.data != null && _existingVehicle == null) {
          _populateForm(next.data!);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '차량 수정' : '차량 추가'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 기본 정보
            _buildSectionTitle('기본 정보'),
            const SizedBox(height: 12),
            _buildPlateNumberField(),
            const SizedBox(height: 16),
            _buildManufacturerField(),
            const SizedBox(height: 16),
            _buildModelField(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildYearField()),
                const SizedBox(width: 16),
                Expanded(child: _buildColorField()),
              ],
            ),
            const SizedBox(height: 24),

            // 차량 타입 및 승차 정원
            _buildSectionTitle('차량 타입 및 정원'),
            const SizedBox(height: 12),
            _buildVehicleTypeDropdown(),
            const SizedBox(height: 16),
            _buildCapacityField(),
            const SizedBox(height: 24),

            // 상태 (수정 모드에서만 표시)
            if (_isEditMode) ...[
              _buildSectionTitle('차량 상태'),
              const SizedBox(height: 12),
              _buildStatusDropdown(),
              const SizedBox(height: 24),
            ],

            // 보험 및 검사 만료일 (수정 모드에서만 표시)
            if (_isEditMode) ...[
              _buildSectionTitle('보험 및 검사'),
              const SizedBox(height: 12),
              _buildInsuranceExpiryField(),
              const SizedBox(height: 16),
              _buildInspectionExpiryField(),
              const SizedBox(height: 24),
            ],

            // 저장 버튼
            const SizedBox(height: 16),
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

  Widget _buildPlateNumberField() {
    return TextFormField(
      controller: _plateNumberController,
      decoration: const InputDecoration(
        labelText: '차량 번호',
        hintText: '예: 12가3456',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.numbers),
      ),
      enabled: !_isEditMode, // 수정 시에는 차량번호 변경 불가
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '차량 번호를 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildManufacturerField() {
    return TextFormField(
      controller: _manufacturerController,
      decoration: const InputDecoration(
        labelText: '제조사',
        hintText: '예: 현대',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '제조사를 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildModelField() {
    return TextFormField(
      controller: _modelController,
      decoration: const InputDecoration(
        labelText: '모델명',
        hintText: '예: 스타리아',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.directions_car),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '모델명을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      controller: _yearController,
      decoration: const InputDecoration(
        labelText: '연식',
        hintText: '예: 2024',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '연식을 입력해주세요';
        }
        final year = int.tryParse(value);
        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
          return '올바른 연식을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildColorField() {
    return TextFormField(
      controller: _colorController,
      decoration: const InputDecoration(
        labelText: '색상',
        hintText: '예: 흰색',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.palette),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '색상을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return DropdownButtonFormField<VehicleType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: '차량 타입',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: VehicleType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getTypeLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
          // 차량 타입에 따라 기본 정원 설정
          _setDefaultCapacity(value);
        }
      },
    );
  }

  Widget _buildCapacityField() {
    return TextFormField(
      controller: _capacityController,
      decoration: const InputDecoration(
        labelText: '최대 승차 인원',
        hintText: '예: 12',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        suffixText: '명',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '승차 인원을 입력해주세요';
        }
        final capacity = int.tryParse(value);
        if (capacity == null || capacity <= 0 || capacity > 100) {
          return '올바른 승차 인원을 입력해주세요 (1-100)';
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<VehicleStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: '차량 상태',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info),
      ),
      items: VehicleStatus.values.map((status) {
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

  Widget _buildInsuranceExpiryField() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return InkWell(
      onTap: () => _selectDate(
        context,
        _insuranceExpiry,
        (date) => setState(() => _insuranceExpiry = date),
      ),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '보험 만료일',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.shield),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _insuranceExpiry != null
              ? dateFormat.format(_insuranceExpiry!)
              : '날짜 선택',
          style: _insuranceExpiry == null
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }

  Widget _buildInspectionExpiryField() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return InkWell(
      onTap: () => _selectDate(
        context,
        _inspectionExpiry,
        (date) => setState(() => _inspectionExpiry = date),
      ),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '검사 만료일',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.assignment_turned_in),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _inspectionExpiry != null
              ? dateFormat.format(_inspectionExpiry!)
              : '날짜 선택',
          style: _inspectionExpiry == null
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _submitForm,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_isEditMode ? '수정 완료' : '차량 추가'),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  /// 차량 타입에 따른 기본 정원 설정
  void _setDefaultCapacity(VehicleType type) {
    int defaultCapacity;
    switch (type) {
      case VehicleType.bus:
        defaultCapacity = 45;
        break;
      case VehicleType.miniBus:
        defaultCapacity = 25;
        break;
      case VehicleType.van:
        defaultCapacity = 12;
        break;
      case VehicleType.sedan:
        defaultCapacity = 5;
        break;
    }
    if (_capacityController.text.isEmpty) {
      _capacityController.text = defaultCapacity.toString();
    }
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
        final dto = UpdateVehicleDto(
          manufacturer: _manufacturerController.text,
          model: _modelController.text,
          vehicleType: _selectedType,
          capacity: int.parse(_capacityController.text),
          year: int.parse(_yearController.text),
          color: _colorController.text,
          status: _selectedStatus,
          insuranceExpiry: _insuranceExpiry,
          inspectionExpiry: _inspectionExpiry,
        );

        await ref
            .read(vehicleActionsProvider)
            .updateVehicle(widget.vehicleId!, dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('차량 정보가 수정되었습니다')),
          );
          context.pop();
        }
      } else {
        // 추가
        final dto = CreateVehicleDto(
          plateNumber: _plateNumberController.text,
          manufacturer: _manufacturerController.text,
          model: _modelController.text,
          vehicleType: _selectedType,
          capacity: int.parse(_capacityController.text),
          year: int.parse(_yearController.text),
          color: _colorController.text,
        );

        final vehicle = await ref.read(vehicleActionsProvider).createVehicle(dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('차량이 추가되었습니다')),
          );
          // 상세 화면으로 이동
          context.go('/vehicles/${vehicle.id}');
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

  String _getStatusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return '운행중';
      case VehicleStatus.maintenance:
        return '정비중';
      case VehicleStatus.inactive:
        return '비활성';
    }
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.active:
        return Colors.green;
      case VehicleStatus.maintenance:
        return Colors.orange;
      case VehicleStatus.inactive:
        return Colors.grey;
    }
  }

  String _getTypeLabel(VehicleType type) {
    switch (type) {
      case VehicleType.van:
        return '승합차';
      case VehicleType.bus:
        return '버스';
      case VehicleType.miniBus:
        return '소형버스';
      case VehicleType.sedan:
        return '승용차';
    }
  }
}
