import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';
import 'package:cow_management/providers/DetailPage/Health/weight_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class WeightAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const WeightAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<WeightAddPage> createState() => _WeightAddPageState();
}

class _WeightAddPageState extends State<WeightAddPage> {
  final _formKey = GlobalKey<FormState>();

  // 컨트롤러들
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _chestController = TextEditingController();
  final _measuredByController = TextEditingController();
  final _notesController = TextEditingController();

  // 상태 변수들
  String _measurementMethod = '체중계';
  double _bodyConditionScore = 3.0;
  String _weightCategory = '정상';
  bool _isSubmitting = false;

  // 옵션들
  final List<String> _measurementMethods = ['체중계', '체중추정기', '줄자측정', '목측', '기타'];
  final List<String> _weightCategories = ['저체중', '정상', '과체중', '비만'];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
    // 기본 시간 문자열로 설정
    final now = TimeOfDay.now();
    _timeController.text =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context가 완전히 초기화된 후에 올바른 형식으로 업데이트
    if (_timeController.text.contains(':') &&
        _timeController.text.length == 5) {
      final time = TimeOfDay.now();
      _timeController.text = time.format(context);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _chestController.dispose();
    _measuredByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 체중측정 기록 추가'),
        backgroundColor: Colors.purple,
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
              _buildMeasurementCard(),
              const SizedBox(height: 16),
              _buildBodyConditionCard(),
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
            const Text('⚖️ 기본 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _measuredByController,
              decoration: const InputDecoration(
                labelText: '측정자',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? '측정자를 입력해주세요' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: '측정일 *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      validator: (value) => value?.isEmpty == true ? '측정일을 선택해주세요' : null,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          _dateController.text = date.toString().split(' ')[0];
        }
      },
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      decoration: const InputDecoration(
        labelText: '측정 시간',
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
          _timeController.text = time.format(context);
        }
      },
    );
  }

  Widget _buildMeasurementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📏 측정 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdownField(
                '측정 방법', _measurementMethod, _measurementMethods, (value) {
              setState(() => _measurementMethod = value!);
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: '체중 (kg) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                      hintText: '예: 450.5',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value?.isEmpty == true ? '체중을 입력해주세요' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField(
                      '체중 분류', _weightCategory, _weightCategories, (value) {
                    setState(() => _weightCategory = value!);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: '체고 (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                      hintText: '예: 140',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _chestController,
                    decoration: const InputDecoration(
                      labelText: '흉위 (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                      hintText: '예: 180',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyConditionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 체형 평가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('체형 점수 (BCS)',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            const SizedBox(height: 8),
            Slider(
              value: _bodyConditionScore,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: _bodyConditionScore.toStringAsFixed(1),
              onChanged: (value) => setState(() => _bodyConditionScore = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1.0 (매우 마름)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('현재: ${_bodyConditionScore.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                Text('5.0 (매우 비만)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BCS 참고 기준:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('1.0-2.0: 매우 마름 (영양 보충 필요)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text('2.5-3.5: 정상 (이상적인 체형)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text('4.0-5.0: 과체중/비만 (사료 조절 필요)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
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
            const Text('📝 추가 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '특이사항 및 메모',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: '체중 변화 원인, 건강 상태 등을 기록하세요',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSubmitting ? Colors.grey : Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('저장 중...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Text('체중측정 기록 저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;

      final newRecord = WeightRecord(
        cowId: widget.cowId,
        recordDate: _dateController.text,
        measurementTime: _timeController.text,
        weight: double.tryParse(_weightController.text),
        measurementMethod: _measurementMethod,
        bodyConditionScore: _bodyConditionScore,
        heightWithers: double.tryParse(_heightController.text),
        chestGirth: double.tryParse(_chestController.text),
        weightCategory: _weightCategory,
        measurer: _measuredByController.text,
        notes: _notesController.text,
      );

      await Provider.of<WeightRecordProvider>(context, listen: false)
          .addRecord(newRecord, token!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('체중측정 기록이 저장되었습니다'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
