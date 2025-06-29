import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/estrus_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class EstrusAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const EstrusAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<EstrusAddPage> createState() => _EstrusAddPageState();
}

class _EstrusAddPageState extends State<EstrusAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // 컨트롤러들
  final _startTimeController = TextEditingController();
  final _durationController = TextEditingController();
  final _behaviorSignsController = TextEditingController();
  final _visualSignsController = TextEditingController();
  final _detectedByController = TextEditingController();
  final _notesController = TextEditingController();
  
  // 상태 변수들
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String? _estrusIntensity;
  String? _detectionMethod;
  DateTime? _nextExpectedEstrus;
  bool _breedingPlanned = false;

  @override
  void dispose() {
    _startTimeController.dispose();
    _durationController.dispose();
    _behaviorSignsController.dispose();
    _visualSignsController.dispose();
    _detectedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _startTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  Future<void> _selectNextEstrusDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextExpectedEstrus ?? DateTime.now().add(const Duration(days: 21)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _nextExpectedEstrus = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final record = EstrusRecord(
      cowId: widget.cowId,
      recordDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      estrusStartTime: _startTimeController.text.isNotEmpty ? _startTimeController.text : null,
      estrusIntensity: _estrusIntensity,
      estrusDuration: int.tryParse(_durationController.text),
      behaviorSigns: _behaviorSignsController.text.isNotEmpty 
          ? _behaviorSignsController.text.split(',').map((e) => e.trim()).toList()
          : null,
      visualSigns: _visualSignsController.text.isNotEmpty 
          ? _visualSignsController.text.split(',').map((e) => e.trim()).toList()
          : null,
      detectedBy: _detectedByController.text.isNotEmpty ? _detectedByController.text : null,
      detectionMethod: _detectionMethod,
      nextExpectedEstrus: _nextExpectedEstrus != null 
          ? DateFormat('yyyy-MM-dd').format(_nextExpectedEstrus!)
          : null,
      breedingPlanned: _breedingPlanned,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final success = await Provider.of<EstrusRecordProvider>(context, listen: false)
        .addEstrusRecord(record, token);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('발정 기록이 성공적으로 등록되었습니다!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('발정 기록 등록에 실패했습니다.'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text('${widget.cowName} - 발정 기록 추가'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 💕 기본 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.pink, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          '기본 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 발정 날짜
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '발정 날짜 *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 발정 시작 시간
                    TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      onTap: _selectTime,
                      decoration: const InputDecoration(
                        labelText: '발정 시작 시간',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                        hintText: '시간을 선택하세요',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 발정 강도
                    DropdownButtonFormField<String>(
                      value: _estrusIntensity,
                      decoration: const InputDecoration(
                        labelText: '발정 강도',
                        border: OutlineInputBorder(),
                      ),
                      items: ['약', '중', '강'].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _estrusIntensity = val),
                    ),
                    const SizedBox(height: 16),
                    
                    // 발정 지속시간
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '발정 지속시간 (시간)',
                        border: OutlineInputBorder(),
                        hintText: '예: 12',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 발정 징후 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          '발정 징후',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 행동 징후
                    TextFormField(
                      controller: _behaviorSignsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '행동 징후',
                        border: OutlineInputBorder(),
                        hintText: '승가허용, 불안, 울음 등 (쉼표로 구분)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 육안 관찰 사항
                    TextFormField(
                      controller: _visualSignsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '육안 관찰 사항',
                        border: OutlineInputBorder(),
                        hintText: '점액분비, 외음부종 등 (쉼표로 구분)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 👤 발견 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_search, color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          '발견 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 발견자
                    TextFormField(
                      controller: _detectedByController,
                      decoration: const InputDecoration(
                        labelText: '발견자 이름',
                        border: OutlineInputBorder(),
                        hintText: '발견한 사람의 이름',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 발견 방법
                    DropdownButtonFormField<String>(
                      value: _detectionMethod,
                      decoration: const InputDecoration(
                        labelText: '발견 방법',
                        border: OutlineInputBorder(),
                      ),
                      items: ['육안관찰', '센서감지', '기타'].map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _detectionMethod = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📅 계획 및 예측 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          '계획 및 예측',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 다음 발정 예상일
                    InkWell(
                      onTap: _selectNextEstrusDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '다음 발정 예상일',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _nextExpectedEstrus != null 
                              ? DateFormat('yyyy-MM-dd').format(_nextExpectedEstrus!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: _nextExpectedEstrus != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 교배 계획
                    SwitchListTile(
                      title: const Text('교배 계획 있음'),
                      subtitle: const Text('이번 발정에 교배를 계획하고 있습니까?'),
                      value: _breedingPlanned,
                      onChanged: (val) => setState(() => _breedingPlanned = val),
                      activeColor: Colors.pink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 추가 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.note_alt, color: Colors.purple, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          '추가 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 메모
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '특이사항 및 메모',
                        border: OutlineInputBorder(),
                        hintText: '추가로 기록할 내용이 있다면 입력하세요',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
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
                          Text('등록 중...'),
                        ],
                      )
                    : const Text(
                        '발정 기록 저장',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
