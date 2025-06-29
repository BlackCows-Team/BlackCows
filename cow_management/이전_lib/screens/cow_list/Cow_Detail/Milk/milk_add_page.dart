import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/providers/user_provider.dart';

class MilkingRecordPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const MilkingRecordPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<MilkingRecordPage> createState() => _MilkingRecordPageState();
}

class _MilkingRecordPageState extends State<MilkingRecordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // 날짜 및 시간
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  // 필수 필드 컨트롤러
  final _milkYieldController = TextEditingController();
  final _milkingSessionController = TextEditingController();
  
  // 품질 정보 컨트롤러
  final _fatPercentageController = TextEditingController();
  final _proteinPercentageController = TextEditingController();
  final _somaticCellCountController = TextEditingController();
  final _conductivityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _colorValueController = TextEditingController();
  
  // 기타 정보 컨트롤러
  final _lactationNumberController = TextEditingController();
  final _ruminationTimeController = TextEditingController();
  final _airFlowValueController = TextEditingController();
  final _collectionCodeController = TextEditingController();
  final _collectionCountController = TextEditingController();
  final _notesController = TextEditingController();
  
  // 상태 변수
  bool _bloodFlowDetected = false;

  @override
  void dispose() {
    _milkYieldController.dispose();
    _milkingSessionController.dispose();
    _fatPercentageController.dispose();
    _proteinPercentageController.dispose();
    _somaticCellCountController.dispose();
    _conductivityController.dispose();
    _temperatureController.dispose();
    _colorValueController.dispose();
    _lactationNumberController.dispose();
    _ruminationTimeController.dispose();
    _airFlowValueController.dispose();
    _collectionCodeController.dispose();
    _collectionCountController.dispose();
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

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'];

    if (token == null || apiUrl == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final body = {
      "cow_id": widget.cowId,
      "record_date": DateFormat("yyyy-MM-dd").format(_selectedDate),
      "milk_yield": double.tryParse(_milkYieldController.text) ?? 0,
      "milking_start_time": _startTime != null ? _formatTimeOfDay(_startTime!) : null,
      "milking_end_time": _endTime != null ? _formatTimeOfDay(_endTime!) : null,
      "milking_session": int.tryParse(_milkingSessionController.text) ?? 1,
      "conductivity": _conductivityController.text.isNotEmpty 
          ? double.tryParse(_conductivityController.text) 
          : null,
      "somatic_cell_count": _somaticCellCountController.text.isNotEmpty 
          ? int.tryParse(_somaticCellCountController.text) 
          : null,
      "blood_flow_detected": _bloodFlowDetected,
      "color_value": _colorValueController.text.isNotEmpty ? _colorValueController.text : null,
      "temperature": _temperatureController.text.isNotEmpty 
          ? double.tryParse(_temperatureController.text) 
          : null,
      "fat_percentage": _fatPercentageController.text.isNotEmpty 
          ? double.tryParse(_fatPercentageController.text) 
          : null,
      "protein_percentage": _proteinPercentageController.text.isNotEmpty 
          ? double.tryParse(_proteinPercentageController.text) 
          : null,
      "air_flow_value": _airFlowValueController.text.isNotEmpty 
          ? double.tryParse(_airFlowValueController.text) 
          : null,
      "lactation_number": _lactationNumberController.text.isNotEmpty 
          ? int.tryParse(_lactationNumberController.text) 
          : null,
      "rumination_time": _ruminationTimeController.text.isNotEmpty 
          ? int.tryParse(_ruminationTimeController.text) 
          : null,
      "collection_code": _collectionCodeController.text.isNotEmpty ? _collectionCodeController.text : null,
      "collection_count": _collectionCountController.text.isNotEmpty 
          ? int.tryParse(_collectionCountController.text) 
          : null,
      "notes": _notesController.text.isNotEmpty ? _notesController.text : null,
    };

    try {
      final response = await dio.post(
        "$apiUrl/records/milking",
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('착유 기록이 성공적으로 등록되었습니다!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(
            context,
            '/milking-records',
            arguments: {
              'cowId': widget.cowId,
              'cowName': widget.cowName,
            },
          );
        }
      } else {
        throw Exception("등록 실패");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("착유 기록 등록 실패: $e")),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('${widget.cowName} - 착유 기록 추가'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🥛 기본 착유 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_drink, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '기본 착유 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 착유 날짜
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '착유 날짜 *',
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
                    
                    // 착유 시작 시간
                    InkWell(
                      onTap: _selectStartTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '착유 시작 시간',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _startTime != null 
                              ? _formatTimeOfDay(_startTime!)
                              : '시간을 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: _startTime != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 착유 종료 시간
                    InkWell(
                      onTap: _selectEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '착유 종료 시간',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _endTime != null 
                              ? _formatTimeOfDay(_endTime!)
                              : '시간을 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: _endTime != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 우유 생산량 (필수)
                    TextFormField(
                      controller: _milkYieldController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '우유 생산량 (L) *',
                        border: OutlineInputBorder(),
                        hintText: '예: 25.5',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '우유 생산량은 필수 입력 항목입니다.';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return '올바른 우유 생산량을 입력하세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 착유 회차
                    TextFormField(
                      controller: _milkingSessionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '착유 회차 *',
                        border: OutlineInputBorder(),
                        hintText: '예: 1 (1회차), 2 (2회차)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '착유 회차는 필수 입력 항목입니다.';
                        }
                        final session = int.tryParse(value);
                        if (session == null || session <= 0) {
                          return '올바른 착유 회차를 입력하세요.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🧪 우유 품질 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '우유 품질 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 유지방 함량
                    TextFormField(
                      controller: _fatPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '유지방 함량 (%)',
                        border: OutlineInputBorder(),
                        hintText: '예: 3.8',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 단백질 함량
                    TextFormField(
                      controller: _proteinPercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '단백질 함량 (%)',
                        border: OutlineInputBorder(),
                        hintText: '예: 3.2',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 체세포 수
                    TextFormField(
                      controller: _somaticCellCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '체세포 수',
                        border: OutlineInputBorder(),
                        hintText: '예: 150000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 전도도
                    TextFormField(
                      controller: _conductivityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '전도도',
                        border: OutlineInputBorder(),
                        hintText: '예: 5.2',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 온도
                    TextFormField(
                      controller: _temperatureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '온도 (℃)',
                        border: OutlineInputBorder(),
                        hintText: '예: 37.5',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 우유 색상
                    TextFormField(
                      controller: _colorValueController,
                      decoration: const InputDecoration(
                        labelText: '우유 색상',
                        border: OutlineInputBorder(),
                        hintText: '예: 정상, 이상',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 혈류 감지 여부
                    SwitchListTile(
                      title: const Text('혈류 감지 여부'),
                      subtitle: const Text('우유에서 혈류가 감지되었습니까?'),
                      value: _bloodFlowDetected,
                      onChanged: (val) => setState(() => _bloodFlowDetected = val),
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 추가 측정 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.orange, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '추가 측정 정보',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 산차
                    TextFormField(
                      controller: _lactationNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '산차',
                        border: OutlineInputBorder(),
                        hintText: '예: 3',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 반추 시간
                    TextFormField(
                      controller: _ruminationTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '반추 시간 (분)',
                        border: OutlineInputBorder(),
                        hintText: '예: 480',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 공기 흐름 값
                    TextFormField(
                      controller: _airFlowValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '공기 흐름 값',
                        border: OutlineInputBorder(),
                        hintText: '예: 2.1',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 수집 코드
                    TextFormField(
                      controller: _collectionCodeController,
                      decoration: const InputDecoration(
                        labelText: '수집 코드',
                        border: OutlineInputBorder(),
                        hintText: '예: AUTO',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 수집 횟수
                    TextFormField(
                      controller: _collectionCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '수집 횟수',
                        border: OutlineInputBorder(),
                        hintText: '예: 1',
                      ),
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
                    const Row(
                      children: [
                        Icon(Icons.note_alt, color: Colors.purple, size: 24),
                        SizedBox(width: 8),
                        Text(
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
                    
                    // 비고 및 메모
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '비고 및 메모',
                        border: OutlineInputBorder(),
                        hintText: '착유 과정에서 특이사항이나 메모를 입력하세요',
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
                onPressed: _isLoading ? null : _submitRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                        '착유 기록 저장',
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
