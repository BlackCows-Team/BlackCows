import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/services/dio_client.dart';

class CowEditPage extends StatefulWidget {
  final Cow cow;

  const CowEditPage({super.key, required this.cow});

  @override
  State<CowEditPage> createState() => _CowEditPageState();
}

class _CowEditPageState extends State<CowEditPage> {
  late TextEditingController nameController;
  late TextEditingController sensorController;
  late TextEditingController breedController;
  late TextEditingController notesController;

  DateTime? _selectedBirthdate;
  HealthStatus? _selectedHealthStatus;
  BreedingStatus? _selectedBreedingStatus;
  bool _isLoading = false;

  // 한국어 매칭
  final healthStatusLabels = {
    HealthStatus.normal: '양호',
    HealthStatus.warning: '경고',
    HealthStatus.danger: '위험',
  };

  final breedingStatusLabels = {
    BreedingStatus.calf: '송아지',
    BreedingStatus.heifer: '미경산',
    BreedingStatus.pregnant: '임신',
    BreedingStatus.lactating: '비유',
    BreedingStatus.dry: '건유',
    BreedingStatus.breeding: '교배',
  };

  @override
  void initState() {
    super.initState();
    final cow = widget.cow;
    nameController = TextEditingController(text: cow.name);
    sensorController = TextEditingController(text: cow.sensorNumber ?? '');
    breedController = TextEditingController(text: cow.breed ?? '');
    notesController = TextEditingController(text: cow.notes ?? '');
    _selectedBirthdate = cow.birthdate;
    _selectedHealthStatus = cow.healthStatus;
    _selectedBreedingStatus = cow.breedingStatus;
  }

  @override
  void dispose() {
    nameController.dispose();
    sensorController.dispose();
    breedController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthdate = picked);
    }
  }

  Future<void> _updateCow() async {
    if (_isLoading) return;

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 필수 입력 항목입니다!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cowData = {
        'name': nameController.text.trim(),
        if (_selectedBirthdate != null)
          'birthdate': _selectedBirthdate!.toIso8601String().split('T')[0],
        if (sensorController.text.trim().isNotEmpty)
          'sensor_number': sensorController.text.trim(),
        if (_selectedHealthStatus != null)
          'health_status': _selectedHealthStatus!.name,
        if (_selectedBreedingStatus != null)
          'breeding_status': _selectedBreedingStatus!.name,
        if (breedController.text.trim().isNotEmpty)
          'breed': breedController.text.trim(),
        if (notesController.text.trim().isNotEmpty)
          'notes': notesController.text.trim(),
      };

      final response = await DioClient().dio.put(
            '/cows/${widget.cow.id}',
            data: cowData,
          );

      final updatedCow = Cow.fromJson(response.data);
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      cowProvider.updateCow(updatedCow);

      if (!mounted) return;
      Navigator.pop(context, updatedCow);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message;

      if (data is Map<String, dynamic> && data['detail'] != null) {
        if (data['detail'] is String) {
          message = data['detail'];
        } else if (data['detail'] is List) {
          message = data['detail'].first.toString();
        } else {
          message = '알 수 없는 오류가 발생했어요.';
        }
      } else {
        message = '소 수정 실패: ${e.message}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('소 정보 수정')),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이름 *'),
            TextField(controller: nameController),
            const SizedBox(height: 16),
            const Text('출생일'),
            InkWell(
              onTap: _selectBirthdate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedBirthdate?.toLocal().toString().split(' ')[0] ??
                      '날짜 선택',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('센서 번호'),
            TextField(controller: sensorController),
            const SizedBox(height: 16),
            const Text('건강 상태'),
            DropdownButton<HealthStatus>(
              value: _selectedHealthStatus,
              hint: const Text('선택'),
              items: HealthStatus.values.map((status) {
                String displayName;
                switch (status) {
                  case HealthStatus.normal:
                    displayName = '양호';
                    break;
                  case HealthStatus.warning:
                    displayName = '경고';
                    break;
                  case HealthStatus.danger:
                    displayName = '위험';
                    break;
                }
                return DropdownMenuItem(
                  value: status,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedHealthStatus = val),
            ),
            const SizedBox(height: 16),
            const Text('번식 상태'),
            DropdownButton<BreedingStatus>(
              value: _selectedBreedingStatus,
              hint: const Text('선택'),
              items: BreedingStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(breedingStatusLabels[status]!),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBreedingStatus = val),
            ),
            const SizedBox(height: 16),
            const Text('품종'),
            TextField(controller: breedController),
            const SizedBox(height: 16),
            const Text('메모'),
            TextField(controller: notesController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateCow,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
