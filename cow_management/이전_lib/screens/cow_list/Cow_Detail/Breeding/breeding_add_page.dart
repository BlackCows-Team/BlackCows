import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/breeding_record.dart';
import 'package:cow_management/providers/DetailPage/breeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:intl/intl.dart';

class BreedingRecordAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const BreedingRecordAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<BreedingRecordAddPage> createState() => _BreedingRecordAddPageState();
}

class _BreedingRecordAddPageState extends State<BreedingRecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _methodController = TextEditingController(text: 'artificial');
  final _bullInfoController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _locationController = TextEditingController();
  final _staffController = TextEditingController();
  final _costController = TextEditingController();

  String _selectedResult = 'pending';
  DateTime breedingDate = DateTime.now();
  DateTime expectedCalvingDate = DateTime.now().add(const Duration(days: 280));
  DateTime pregnancyCheckDate = DateTime.now().add(const Duration(days: 30));

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _methodController.dispose();
    _bullInfoController.dispose();
    _veterinarianController.dispose();
    _locationController.dispose();
    _staffController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('번식 기록 추가')),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("소: ${widget.cowName}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_titleController, '제목'),
              _buildTextField(_descController, '설명'),
              _buildTextField(_methodController, '번식 방법 (예: artificial)'),
              _buildTextField(_bullInfoController, '수소 정보'),
              _buildTextField(_veterinarianController, '수의사 이름'),
              _buildTextField(_locationController, '인공수정 장소'),
              _buildTextField(_staffController, '담당자'),
              _buildTextField(_costController, '비용 (숫자)'),
              _buildDateField('번식일', breedingDate,
                  (picked) => setState(() => breedingDate = picked)),
              _buildDateField('예상 분만일', expectedCalvingDate,
                  (picked) => setState(() => expectedCalvingDate = picked)),
              _buildDateField('임신 검사일', pregnancyCheckDate,
                  (picked) => setState(() => pregnancyCheckDate = picked)),
              DropdownButtonFormField<String>(
                value: _selectedResult,
                decoration: const InputDecoration(labelText: '번식 결과'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('예정')),
                  DropdownMenuItem(value: 'success', child: Text('성공')),
                  DropdownMenuItem(value: 'fail', child: Text('실패')),
                ],
                onChanged: (value) => setState(() => _selectedResult = value!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: const Text('기록 추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? '$label을 입력하세요' : null,
      ),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, ValueChanged<DateTime> onPicked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              child: Text('$label: ${DateFormat('yyyy-MM-dd').format(date)}')),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) onPicked(picked);
            },
            child: const Text('날짜 선택'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final record = BreedingRecord(
      id: '',
      cowId: widget.cowId,
      recordType: 'breeding',
      recordDate: DateTime.now().toIso8601String().split('T')[0],
      title: _titleController.text,
      description: _descController.text,
      breedingMethod: _methodController.text,
      breedingDate: breedingDate.toIso8601String().split('T')[0],
      bullInfo: _bullInfoController.text,
      expectedCalvingDate: expectedCalvingDate.toIso8601String().split('T')[0],
      pregnancyCheckDate: pregnancyCheckDate.toIso8601String().split('T')[0],
      breedingResult: _selectedResult,
      cost: int.tryParse(_costController.text) ?? 0,
      veterinarian: _veterinarianController.text,
    );

    try {
      await Provider.of<BreedingRecordProvider>(context, listen: false)
          .addRecord(record, token!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록이 추가되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추가 실패: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
