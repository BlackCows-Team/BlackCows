import 'package:flutter/material.dart';
import 'analysis_tab_controller.dart';
import 'analysis_input_mode_toggle.dart';
import 'analysis_form_autofill.dart';
import 'analysis_form_manual.dart';
import 'analysis_result_card.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String selectedServiceId = 'milk_yield';
  String inputMode = '소 선택';

  void _predict(String? temperature, String? milkVolume) {
    if (temperature == null ||
        temperature.isEmpty ||
        milkVolume == null ||
        milkVolume.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ 입력값 부족'),
          content: const Text('예측에 필요한 정보가 부족해요.\n모든 항목을 채워주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // 예측 실행
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI 예측을 시작합니다.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedService =
        analysisTabs.firstWhere((s) => s.id == selectedServiceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 서비스'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔸 AI 서비스 선택 버튼
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: analysisTabs.map((service) {
                final isSelected = selectedServiceId == service.id;
                return GestureDetector(
                  onTap: () => setState(() => selectedServiceId = service.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFFC8E6C9) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Color(0xFF4CAF50) : Colors.grey),
                    ),
                    child: Text(
                      service.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Color(0xFF388E3C) : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 🔸 입력 방식 선택
            AnalysisInputModeToggle(
              inputMode: inputMode,
              onChanged: (val) => setState(() => inputMode = val),
            ),
            const SizedBox(height: 16),

            // 🔸 입력 폼
            inputMode == '소 선택'
                ? AnalysisFormAutofill(onPredict: _predict)
                : AnalysisFormManual(onPredict: _predict),

            const SizedBox(height: 20),

            // 🔸 결과
            const AnalysisResultCard(),
          ],
        ),
      ),
    );
  }
}
