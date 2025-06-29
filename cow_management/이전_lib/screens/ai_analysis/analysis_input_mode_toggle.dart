import 'package:flutter/material.dart';

class AnalysisInputModeToggle extends StatelessWidget {
  final String inputMode;
  final ValueChanged<String> onChanged;

  const AnalysisInputModeToggle({
    super.key,
    required this.inputMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        ChoiceChip(
          label: const Text('소 목록에서 불러오기'),
          selected: inputMode == '소 선택',
          onSelected: (_) => onChanged('소 선택'),
        ),
        ChoiceChip(
          label: const Text('직접 입력'),
          selected: inputMode == '직접 입력',
          onSelected: (_) => onChanged('직접 입력'),
        ),
      ],
    );
  }
}
