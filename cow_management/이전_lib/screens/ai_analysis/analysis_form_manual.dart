import 'package:flutter/material.dart';

class AnalysisFormManual extends StatefulWidget {
  final void Function(String? temp, String? milk) onPredict;

  const AnalysisFormManual({required this.onPredict, super.key});

  @override
  State<AnalysisFormManual> createState() => _AnalysisFormManualState();
}

class _AnalysisFormManualState extends State<AnalysisFormManual> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _milkVolumeController = TextEditingController();

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
        const Text("✏️ AI 예측에 필요한 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _temperatureController,
          decoration: const InputDecoration(
            labelText: '체온 (°C)',
            hintText: '직접 입력해 주세요',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _milkVolumeController,
          decoration: const InputDecoration(
            labelText: '하루 평균 착유량 (L)',
            hintText: '직접 입력해 주세요',
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
