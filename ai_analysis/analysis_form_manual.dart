import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'analysis_tab_controller.dart';

class AnalysisFormManual extends StatefulWidget {
  final void Function(String? temp, String? milk) onPredict;
  final String selectedServiceId;

  const AnalysisFormManual({
    required this.onPredict, 
    required this.selectedServiceId,
    super.key
  });

  @override
  State<AnalysisFormManual> createState() => _AnalysisFormManualState();
}

class _AnalysisFormManualState extends State<AnalysisFormManual> {
  final Map<String, TextEditingController> _controllers = {};

  // 필드 매핑
  final Map<String, Map<String, dynamic>> _fieldMapping = {
    '착유횟수': {'key': 'milkingFreq', 'label': '착유횟수 (회/일)', 'hint': '2', 'icon': Icons.schedule},
    '사료섭취량': {'key': 'feedIntake', 'label': '사료섭취량 (kg)', 'hint': '25.0', 'icon': Icons.grass},
    '온도': {'key': 'temperature', 'label': '환경온도 (°C)', 'hint': '20', 'icon': Icons.thermostat},
    '유지방비율': {'key': 'fatRatio', 'label': '유지방비율 (%)', 'hint': '3.8', 'icon': Icons.opacity},
    '전도율': {'key': 'conductivity', 'label': '전도율 (mS/cm)', 'hint': '4.2', 'icon': Icons.electric_bolt},
    '유단백비율': {'key': 'proteinRatio', 'label': '유단백비율 (%)', 'hint': '3.2', 'icon': Icons.science},
    '체세포수 또는 생체지표': {'key': 'scc', 'label': '체세포수 (cells/mL)', 'hint': '200000', 'icon': Icons.biotech},
    '착유량': {'key': 'milkVolume', 'label': '착유량 (L)', 'hint': '18.5', 'icon': Icons.water_drop},
    '산차수': {'key': 'parity', 'label': '산차수', 'hint': '2', 'icon': Icons.child_care},
    '질병이력': {'key': 'diseaseHistory', 'label': '질병이력', 'hint': '없음', 'icon': Icons.medical_services},
    '체중': {'key': 'weight', 'label': '체중 (kg)', 'hint': '650', 'icon': Icons.monitor_weight},
    '활동량': {'key': 'activity', 'label': '활동량', 'hint': '보통', 'icon': Icons.directions_walk},
    '체형점수': {'key': 'bodyScore', 'label': '체형점수', 'hint': '3.5', 'icon': Icons.assessment},
    '수정일': {'key': 'breedingDate', 'label': '수정일', 'hint': '2024-01-15', 'icon': Icons.calendar_today},
    '공태일수': {'key': 'daysOpen', 'label': '공태일수', 'hint': '45', 'icon': Icons.timer},
    '이전분만일': {'key': 'lastCalvingDate', 'label': '이전분만일', 'hint': '2023-12-01', 'icon': Icons.event},
    '수정방법': {'key': 'breedingMethod', 'label': '수정방법', 'hint': '인공수정', 'icon': Icons.medical_information},
    '유방염이력': {'key': 'mastitisHistory', 'label': '유방염이력', 'hint': '없음', 'icon': Icons.warning},
    '체온': {'key': 'temperature', 'label': '체온 (°C)', 'hint': '38.4', 'icon': Icons.thermostat},
    '발정주기': {'key': 'estruscycle', 'label': '발정주기 (일)', 'hint': '21', 'icon': Icons.favorite},
    '마지막분만일': {'key': 'lastCalvingDate', 'label': '마지막분만일', 'hint': '2023-12-01', 'icon': Icons.event},
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    for (final field in selectedService.requiredFields) {
      final fieldInfo = _fieldMapping[field];
      if (fieldInfo != null) {
        _controllers[fieldInfo['key']] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 안내 메시지
        _buildInfoSection(),
        const SizedBox(height: 20),

        // 데이터 입력 섹션
        _buildDataInputSection(),
        const SizedBox(height: 24),

        // 분석 버튼
        _buildAnalysisButton(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '정확한 분석을 위해 모든 항목을 입력해주세요',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataInputSection() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    final fields = selectedService.requiredFields;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              "필수 입력 데이터",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "${selectedService.label}에 필요한 데이터를 직접 입력하세요",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        // 동적으로 필드 생성
        ...List.generate((fields.length / 2).ceil(), (index) {
          final startIndex = index * 2;
          final endIndex = (startIndex + 1 < fields.length) ? startIndex + 1 : startIndex;
          
          if (startIndex == endIndex) {
            // 마지막 필드가 홀수개일 때
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInputFieldFromName(fields[startIndex]),
            );
          } else {
            // 두 개씩 나란히
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(child: _buildInputFieldFromName(fields[startIndex])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputFieldFromName(fields[endIndex])),
                ],
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildInputFieldFromName(String fieldName) {
    final fieldInfo = _fieldMapping[fieldName];
    if (fieldInfo == null) {
      return Container(); // 매핑되지 않은 필드는 빈 컨테이너
    }
    
    final controller = _controllers[fieldInfo['key']];
    if (controller == null) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: fieldInfo['key'] == 'diseaseHistory' || 
                     fieldInfo['key'] == 'breedingMethod' ||
                     fieldInfo['key'] == 'mastitisHistory' ||
                     fieldInfo['key'] == 'activity'
            ? TextInputType.text
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: fieldInfo['key'] == 'diseaseHistory' || 
                        fieldInfo['key'] == 'breedingMethod' ||
                        fieldInfo['key'] == 'mastitisHistory' ||
                        fieldInfo['key'] == 'activity'
            ? null
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: fieldInfo['label'],
          hintText: fieldInfo['hint'],
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
        ),
            child: Icon(fieldInfo['icon'], size: 16, color: Colors.grey.shade600),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return SizedBox(
      width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
          // 첫 번째와 두 번째 컨트롤러 값을 전달 (기존 인터페이스 유지)
          final firstValue = _controllers.values.isNotEmpty ? _controllers.values.first.text : '';
          final secondValue = _controllers.values.length > 1 ? _controllers.values.elementAt(1).text : '';
          widget.onPredict(firstValue, secondValue);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 20),
            const SizedBox(width: 8),
            const Text(
              'AI 분석 시작',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
          ),
        ),
      ],
        ),
      ),
    );
  }
}