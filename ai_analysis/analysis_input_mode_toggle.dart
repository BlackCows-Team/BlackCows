import 'package:flutter/material.dart';

class AnalysisInputModeToggle extends StatelessWidget {
  final String inputMode;
  final Function(String) onChanged;

  const AnalysisInputModeToggle({
    required this.inputMode,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              '소 선택',
              Icons.pets,
              '기존 소 데이터 자동 입력',
              inputMode == '소 선택',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleOption(
              '직접 입력',
              Icons.edit,
              '새로운 데이터 직접 입력',
              inputMode == '직접 입력',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String mode, IconData icon, String description, bool isSelected) {
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade400 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              mode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
