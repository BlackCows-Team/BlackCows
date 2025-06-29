import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class HealthCheckAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const HealthCheckAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<HealthCheckAddPage> createState() => _HealthCheckAddPageState();
}

class _HealthCheckAddPageState extends State<HealthCheckAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // 컨트롤러들
  final _recordDateController = TextEditingController();
  final _checkTimeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _examinerController = TextEditingController();
  final _nextCheckDateController = TextEditingController();
  final _notesController = TextEditingController();

  // 상태 변수들
  double _bodyConditionScore = 3.0;
  String _udderCondition = '정상';
  String _hoofCondition = '정상';
  String _coatCondition = '정상';
  String _eyeCondition = '정상';
  String _noseCondition = '정상';
  String _appetite = '정상';
  String _activityLevel = '정상';
  List<String> _selectedSymptoms = [];

  // 옵션들
  final List<String> _conditionOptions = ['정상', '양호', '보통', '나쁨', '매우 나쁨'];
  final List<String> _appetiteOptions = ['매우 좋음', '좋음', '정상', '감소', '없음'];
  final List<String> _activityOptions = ['매우 활발', '활발', '정상', '둔함', '매우 둔함'];
  final List<String> _symptomOptions = [
    '발열', '기침', '설사', '구토', '식욕부진', '무기력', '절뚝거림', 
    '호흡곤란', '눈물', '콧물', '유방염', '발굽병', '기타'
  ];

  @override
  void initState() {
    super.initState();
    _recordDateController.text = DateTime.now().toString().split(' ')[0];
    final now = TimeOfDay.now();
    _checkTimeController.text = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkTimeController.text.contains(':') && _checkTimeController.text.length == 5) {
      final time = TimeOfDay.now();
      _checkTimeController.text = time.format(context);
    }
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _checkTimeController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _examinerController.dispose();
    _nextCheckDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 건강검진 기록 추가'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildVitalSignsCard(),
              const SizedBox(height: 16),
              _buildPhysicalExamCard(),
              const SizedBox(height: 16),
              _buildBehaviorCard(),
              const SizedBox(height: 16),
              _buildSymptomsCard(),
              const SizedBox(height: 16),
              _buildAdditionalInfoCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏥 기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _examinerController,
              decoration: const InputDecoration(
                labelText: '검진자',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty == true ? '검진자를 입력해주세요' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _recordDateController,
      decoration: const InputDecoration(
        labelText: '검진 날짜 *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      validator: (value) => value?.isEmpty == true ? '검진 날짜를 선택해주세요' : null,
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
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _checkTimeController,
      decoration: const InputDecoration(
        labelText: '검진 시간',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          _checkTimeController.text = time.format(context);
        }
      },
    );
  }

  Widget _buildVitalSignsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌡️ 생체 신호', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _temperatureController,
                    decoration: const InputDecoration(
                      labelText: '체온 (°C)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.thermostat),
                      hintText: '예: 38.5',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value?.isEmpty == true ? '체온을 입력해주세요' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(
                      labelText: '심박수 (회/분)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                      hintText: '예: 72',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? '심박수를 입력해주세요' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _respiratoryRateController,
                    decoration: const InputDecoration(
                      labelText: '호흡수 (회/분)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.air),
                      hintText: '예: 24',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? '호흡수를 입력해주세요' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('체형 점수 (BCS)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Slider(
                        value: _bodyConditionScore,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8,
                        label: _bodyConditionScore.toString(),
                        onChanged: (value) => setState(() => _bodyConditionScore = value),
                      ),
                      Text('현재: ${_bodyConditionScore.toStringAsFixed(1)}', 
                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalExamCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔍 신체 검사', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdownField('🐄 유방 상태', _udderCondition, _conditionOptions, (value) {
              setState(() => _udderCondition = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('🦶 발굽 상태', _hoofCondition, _conditionOptions, (value) {
              setState(() => _hoofCondition = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('🧥 털 상태', _coatCondition, _conditionOptions, (value) {
              setState(() => _coatCondition = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('👁️ 눈 상태', _eyeCondition, _conditionOptions, (value) {
              setState(() => _eyeCondition = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('👃 코 상태', _noseCondition, _conditionOptions, (value) {
              setState(() => _noseCondition = value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎭 행동 평가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdownField('🍽️ 식욕', _appetite, _appetiteOptions, (value) {
              setState(() => _appetite = value!);
            }),
            const SizedBox(height: 12),
            _buildDropdownField('🏃 활동 수준', _activityLevel, _activityOptions, (value) {
              setState(() => _activityLevel = value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ 이상 증상', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('해당하는 증상을 선택하세요:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptomOptions.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 추가 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nextCheckDateController,
              decoration: const InputDecoration(
                labelText: '다음 검진 예정일',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  _nextCheckDateController.text = date.toString().split(' ')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '특이사항 및 메모',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: '추가적인 관찰 사항이나 특이사항을 입력하세요',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('건강검진 기록 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;

      final record = HealthCheckRecord(
        id: _uuid.v4(),
        cowId: widget.cowId,
        recordDate: _recordDateController.text,
        checkTime: _checkTimeController.text,
        bodyTemperature: double.tryParse(_temperatureController.text) ?? 0.0,
        heartRate: int.tryParse(_heartRateController.text) ?? 0,
        respiratoryRate: int.tryParse(_respiratoryRateController.text) ?? 0,
        bodyConditionScore: _bodyConditionScore,
        udderCondition: _udderCondition,
        hoofCondition: _hoofCondition,
        coatCondition: _coatCondition,
        eyeCondition: _eyeCondition,
        noseCondition: _noseCondition,
        appetite: _appetite,
        activityLevel: _activityLevel,
        abnormalSymptoms: _selectedSymptoms,
        examiner: _examinerController.text,
                 nextCheckDate: _nextCheckDateController.text.isEmpty ? '' : _nextCheckDateController.text,
         notes: _notesController.text.isEmpty ? '' : _notesController.text,
      );

      try {
        final success = await Provider.of<HealthCheckProvider>(context, listen: false)
            .addRecord(record, token!);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('건강검진 기록이 저장되었습니다'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기록 저장에 실패했습니다'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
