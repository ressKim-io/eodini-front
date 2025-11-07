import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/driver.dart';
import '../providers/driver_provider.dart';
import '../../../core/services/driver_repository.dart';

/// 기사 추가/수정 화면
class DriverFormScreen extends ConsumerStatefulWidget {
  final String? driverId;

  const DriverFormScreen({super.key, this.driverId});

  @override
  ConsumerState<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends ConsumerState<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _notesController = TextEditingController();

  LicenseType _licenseType = LicenseType.type1Regular;
  DateTime _licenseExpiry = DateTime.now().add(const Duration(days: 365));
  DriverStatus _status = DriverStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.driverId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDriverData();
      });
    }
  }

  Future<void> _loadDriverData() async {
    final driver = await ref.read(driverRepositoryProvider).getDriverById(widget.driverId!);
    if (mounted) {
      setState(() {
        _nameController.text = driver.name;
        _phoneController.text = driver.phone;
        _emailController.text = driver.email ?? '';
        _licenseNumberController.text = driver.licenseNumber;
        _addressController.text = driver.address ?? '';
        _emergencyContactController.text = driver.emergencyContact ?? '';
        _notesController.text = driver.notes ?? '';
        _licenseType = driver.licenseType;
        _licenseExpiry = driver.licenseExpiry;
        _status = driver.status;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.driverId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '기사 수정' : '기사 추가'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '전화번호 *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? '전화번호를 입력하세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: '면허번호 *',
                hintText: '11-12-345678-90',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? '면허번호를 입력하세요' : null,
              enabled: !isEdit,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LicenseType>(
              value: _licenseType,
              decoration: const InputDecoration(
                labelText: '면허 종류 *',
                border: OutlineInputBorder(),
              ),
              items: LicenseType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getLicenseTypeLabel(type)),
                );
              }).toList(),
              onChanged: isEdit ? null : (value) => setState(() => _licenseType = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('면허 만료일 *'),
              subtitle: Text(_formatDate(_licenseExpiry)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: '비상 연락처',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            if (isEdit) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<DriverStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: DriverStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? '수정' : '등록'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _licenseExpiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _licenseExpiry = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.driverId != null;

      if (isEdit) {
        await ref.read(driverActionsProvider).updateDriver(
              widget.driverId!,
              UpdateDriverDto(
                name: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text.isEmpty ? null : _emailController.text,
                status: _status,
                licenseExpiry: _licenseExpiry,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                emergencyContact: _emergencyContactController.text.isEmpty ? null : _emergencyContactController.text,
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              ),
            );
      } else {
        await ref.read(driverActionsProvider).createDriver(
              CreateDriverDto(
                name: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text.isEmpty ? null : _emailController.text,
                licenseNumber: _licenseNumberController.text,
                licenseType: _licenseType,
                licenseExpiry: _licenseExpiry,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                emergencyContact: _emergencyContactController.text.isEmpty ? null : _emergencyContactController.text,
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              ),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? '기사가 수정되었습니다' : '기사가 등록되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getLicenseTypeLabel(LicenseType type) {
    switch (type) {
      case LicenseType.type1Regular:
        return '1종 보통';
      case LicenseType.type1Large:
        return '1종 대형';
      case LicenseType.type2Regular:
        return '2종 보통';
    }
  }

  String _getStatusLabel(DriverStatus status) {
    switch (status) {
      case DriverStatus.active:
        return '활동중';
      case DriverStatus.onLeave:
        return '휴가중';
      case DriverStatus.inactive:
        return '비활성';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
