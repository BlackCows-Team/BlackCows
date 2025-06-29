import 'package:flutter/material.dart';

class AnalysisFormAutofill extends StatefulWidget {
  final void Function(String? temp, String? milk) onPredict;

  const AnalysisFormAutofill({required this.onPredict, super.key});

  @override
  State<AnalysisFormAutofill> createState() => _AnalysisFormAutofillState();
}

class _AnalysisFormAutofillState extends State<AnalysisFormAutofill> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _milkVolumeController = TextEditingController();
  String? _selectedCowId;

  void _loadCowData(String cowId) {
    if (cowId == 'cow_1') {
      _temperatureController.text = '38.4';
      _milkVolumeController.text = '';
    } else if (cowId == 'cow_2') {
      _temperatureController.text = '38.1';
      _milkVolumeController.text = '19.2';
    }
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _milkVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔍 소 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCowId,
          items: const [
            DropdownMenuItem(value: 'cow_1', child: Text('보균 소')),
            DropdownMenuItem(value: 'cow_2', child: Text('슬기 소')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCowId = value;
                _loadCowData(value);
              });
            }
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '소를 선택하세요',
          ),
        ),
        const SizedBox(height: 24),
        const Text("✏️ AI 예측에 필요한 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _temperatureController,
          decoration: const InputDecoration(
            labelText: '체온 (°C)',
            hintText: '자동으로 불러오지 않으면 직접 입력해 주세요',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _milkVolumeController,
          decoration: const InputDecoration(
            labelText: '하루 평균 착유량 (L)',
            hintText: '자동으로 불러오지 않으면 직접 입력해 주세요',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () {
              widget.onPredict(_temperatureController.text, _milkVolumeController.text);
            },
            child: const Text('예측하기'),
          ),
        ),
      ],
    );
  }
}
