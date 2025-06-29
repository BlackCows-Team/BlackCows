import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class InseminationRecordAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const InseminationRecordAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<InseminationRecordAddPage> createState() =>
      _InseminationRecordAddPageState();
}

class _InseminationRecordAddPageState extends State<InseminationRecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _recordDateController = TextEditingController();
  final _inseminationTimeController = TextEditingController();
  final _bullInfoController = TextEditingController();
  final _semenQualityController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _costController = TextEditingController();
  final _expectedCalvingDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _successProbabilityController = TextEditingController();

  String _inseminationMethod = '인공수정';
  String _inseminationResult = '대기중';

  @override
  void initState() {
    super.initState();
    _recordDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _inseminationTimeController.dispose();
    _bullInfoController.dispose();
    _semenQualityController.dispose();
    _veterinarianController.dispose();
    _costController.dispose();
    _expectedCalvingDateController.dispose();
    _notesController.dispose();
    _successProbabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 인공수정 기록 추가'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInseminationInfoCard(),
              const SizedBox(height: 16),
              _buildBullInfoCard(),
              const SizedBox(height: 16),
              _buildResultInfoCard(),
              const SizedBox(height: 16),
              _buildMemoCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInseminationInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 인공수정 기본 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recordDateController,
              decoration: const InputDecoration(
                labelText: '수정일 *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? '수정일을 입력해주세요' : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _recordDateController.text = date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inseminationTimeController,
              decoration: const InputDecoration(
                labelText: '수정 시간',
                border: OutlineInputBorder(),
                hintText: '예: 09:30',
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _inseminationMethod,
              decoration: const InputDecoration(
                labelText: '수정 방법',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '인공수정', child: Text('인공수정')),
                DropdownMenuItem(value: '자연교배', child: Text('자연교배')),
                DropdownMenuItem(value: '동기화', child: Text('동기화')),
              ],
              onChanged: (value) =>
                  setState(() => _inseminationMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🐂 종축 및 정액 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bullInfoController,
              decoration: const InputDecoration(
                labelText: '종축 정보',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _semenQualityController,
              decoration: const InputDecoration(
                labelText: '정액 품질',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👨‍⚕️ 수정 결과 및 기타',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _inseminationResult,
              decoration: const InputDecoration(
                labelText: '수정 결과',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '대기중', child: Text('대기중')),
                DropdownMenuItem(value: '성공', child: Text('성공')),
                DropdownMenuItem(value: '실패', child: Text('실패')),
                DropdownMenuItem(value: '재수정필요', child: Text('재수정필요')),
              ],
              onChanged: (value) =>
                  setState(() => _inseminationResult = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _veterinarianController,
              decoration: const InputDecoration(
                labelText: '담당 수의사',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: '비용 (원)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expectedCalvingDateController,
              decoration: const InputDecoration(
                labelText: '분만예정일',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 280)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  _expectedCalvingDateController.text =
                      date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _successProbabilityController,
              decoration: const InputDecoration(
                labelText: '성공 확률 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 메모',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '추가 메모',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('인공수정 기록 저장',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    final record = InseminationRecord(
      cowId: widget.cowId,
      recordDate: _recordDateController.text.trim(),
      inseminationTime: _inseminationTimeController.text.trim().isEmpty
          ? null
          : _inseminationTimeController.text.trim(),
      bullBreed: _bullInfoController.text.trim().isEmpty
          ? null
          : _bullInfoController.text.trim(),
      semenQuality: _semenQualityController.text.trim().isEmpty
          ? null
          : _semenQualityController.text.trim(),
      inseminationMethod: _inseminationMethod,
      technicianName: _veterinarianController.text.trim().isEmpty
          ? null
          : _veterinarianController.text.trim(),
      pregnancyCheckScheduled:
          _expectedCalvingDateController.text.trim().isEmpty
              ? null
              : _expectedCalvingDateController.text.trim(),
      cost: _costController.text.trim().isEmpty
          ? null
          : double.tryParse(_costController.text.trim()),
      successProbability: _successProbabilityController.text.trim().isEmpty
          ? null
          : double.tryParse(_successProbabilityController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken!;
      final provider =
          Provider.of<InseminationRecordProvider>(context, listen: false);
      final success = await provider.addInseminationRecord(record, token);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('인공수정 기록이 저장되었습니다'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('기록 저장에 실패했습니다'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
