import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';
import 'package:cow_management/providers/DetailPage/Health/treatment_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class TreatmentAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const TreatmentAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<TreatmentAddPage> createState() => _TreatmentAddPageState();
}

class _TreatmentAddPageState extends State<TreatmentAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 컨트롤러들
  final _recordDateController = TextEditingController();
  final _treatmentTimeController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _treatmentProcedureController = TextEditingController();
  final _treatmentResponseController = TextEditingController();
  final _treatmentCostController = TextEditingController();
  final _followUpDateController = TextEditingController();
  final _notesController = TextEditingController();

  // 드롭다운 값들
  String? _treatmentType;

  // 드롭다운 옵션들
  final List<String> _treatmentTypes = [
    '일반 치료',
    '응급 치료',
    '예방 치료',
    '수술',
    '검사',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_treatmentTimeController.text.isEmpty) {
      final now = TimeOfDay.now();
      _treatmentTimeController.text = now.format(context);
    }
  }

  void _initializeData() {
    final now = DateTime.now();
    _recordDateController.text = now.toString().split(' ')[0];
    
    final timeNow = TimeOfDay.now();
    final hour = timeNow.hour.toString().padLeft(2, '0');
    final minute = timeNow.minute.toString().padLeft(2, '0');
    _treatmentTimeController.text = '$hour:$minute';
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _treatmentTimeController.dispose();
    _veterinarianController.dispose();
    _diagnosisController.dispose();
    _medicationsController.dispose();
    _treatmentProcedureController.dispose();
    _treatmentResponseController.dispose();
    _treatmentCostController.dispose();
    _followUpDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      controller.text = date.toString().split(' ')[0];
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null && mounted) {
      controller.text = time.format(context);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final record = TreatmentRecord(
        cowId: widget.cowId,
        recordDate: _recordDateController.text,
        treatmentTime: _treatmentTimeController.text.isNotEmpty 
            ? _treatmentTimeController.text 
            : null,
        treatmentType: _treatmentType,
        diagnosis: _diagnosisController.text.isNotEmpty 
            ? _diagnosisController.text 
            : null,
        medicationUsed: _medicationsController.text.isNotEmpty 
            ? [_medicationsController.text] 
            : null,
        treatmentMethod: _treatmentProcedureController.text.isNotEmpty 
            ? _treatmentProcedureController.text 
            : null,
        treatmentResponse: _treatmentResponseController.text.isNotEmpty 
            ? _treatmentResponseController.text 
            : null,
        veterinarian: _veterinarianController.text.isNotEmpty 
            ? _veterinarianController.text 
            : null,
        treatmentCost: _treatmentCostController.text.isNotEmpty 
            ? int.tryParse(_treatmentCostController.text) 
            : null,
        followUpDate: _followUpDateController.text.isNotEmpty 
            ? _followUpDateController.text 
            : null,
        notes: _notesController.text.isNotEmpty 
            ? _notesController.text 
            : null,
      );

      final success = await Provider.of<TreatmentRecordProvider>(context, listen: false)
          .addRecord(record, token);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('치료 기록이 성공적으로 추가되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('치료 기록 추가에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 치료 기록 추가'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 기본 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🩺 기본 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recordDateController,
                        decoration: const InputDecoration(
                          labelText: '치료일 *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) => value?.isEmpty == true ? '치료일을 입력해주세요' : null,
                        onTap: () => _selectDate(_recordDateController),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentTimeController,
                        decoration: const InputDecoration(
                          labelText: '치료 시간',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () => _selectTime(_treatmentTimeController),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _treatmentType,
                        decoration: const InputDecoration(
                          labelText: '치료 유형 *',
                          border: OutlineInputBorder(),
                        ),
                        items: _treatmentTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) => setState(() => _treatmentType = value),
                        validator: (value) => value == null ? '치료 유형을 선택해주세요' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _veterinarianController,
                        decoration: const InputDecoration(
                          labelText: '담당 수의사',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 진단 및 치료 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔍 진단 및 치료 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                          labelText: '진단명 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true ? '진단명을 입력해주세요' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicationsController,
                        decoration: const InputDecoration(
                          labelText: '사용 약물',
                          border: OutlineInputBorder(),
                          hintText: '예: 항생제, 소염제 등',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentProcedureController,
                        decoration: const InputDecoration(
                          labelText: '치료 절차',
                          border: OutlineInputBorder(),
                          hintText: '실시한 치료 방법을 입력하세요',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 치료 결과 및 추가 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 치료 결과 및 추가 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentResponseController,
                        decoration: const InputDecoration(
                          labelText: '치료 반응',
                          border: OutlineInputBorder(),
                          hintText: '치료에 대한 반응을 입력하세요',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _treatmentCostController,
                        decoration: const InputDecoration(
                          labelText: '치료 비용 (원)',
                          border: OutlineInputBorder(),
                          prefixText: '₩ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _followUpDateController,
                        decoration: const InputDecoration(
                          labelText: '추후 검진일',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () => _selectDate(_followUpDateController),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 추가 정보 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 추가 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: '특이사항 및 메모',
                          border: OutlineInputBorder(),
                          hintText: '기타 특이사항이나 추가 메모를 입력하세요',
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('치료 기록 저장 중...'),
                          ],
                        )
                      : const Text(
                          '치료 기록 저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
