import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:flutter/services.dart';
import 'analysis_tab_controller.dart';
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")

class AnalysisFormAutofill extends StatefulWidget {
  final void Function(String? temp, String? milk) onPredict;
  final String selectedServiceId;
  final String? mastitisMode;

  const AnalysisFormAutofill({
    required this.onPredict, 
    required this.selectedServiceId,
    this.mastitisMode,
    super.key
  });

  @override
  State<AnalysisFormAutofill> createState() => _AnalysisFormAutofillState();
}

class _AnalysisFormAutofillState extends State<AnalysisFormAutofill> {
<<<<<<< HEAD
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
=======
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedCowId;

  final List<Map<String, dynamic>> _cowData = [
    {
      'id': 'cow_1',
      'name': '보균',
      'temperature': '38.4',
      'milkVolume': '18.5',
      'feedIntake': '25.0',
      'heartRate': '72',
      'weight': '650',
      'age': '36',
      'milkingFreq': '2',
      'fatRatio': '3.8',
      'proteinRatio': '3.2',
      'conductivity': '4.2',
      'parity': '2',
      'daysOpen': '45',
      'activity': '높음',
      'bodyScore': '3.5',
    },
    {
      'id': 'cow_2',
      'name': '슬기',
      'temperature': '38.1',
      'milkVolume': '19.2',
      'feedIntake': '26.5',
      'heartRate': '68',
      'weight': '680',
      'age': '42',
      'milkingFreq': '3',
      'fatRatio': '3.6',
      'proteinRatio': '3.3',
      'conductivity': '4.0',
      'parity': '3',
      'daysOpen': '32',
      'activity': '보통',
      'bodyScore': '3.8',
    },
    {
      'id': 'cow_3',
      'name': '행복',
      'temperature': '38.6',
      'milkVolume': '17.8',
      'feedIntake': '24.0',
      'heartRate': '75',
      'weight': '620',
      'age': '28',
      'milkingFreq': '2',
      'fatRatio': '4.0',
      'proteinRatio': '3.1',
      'conductivity': '4.5',
      'parity': '1',
      'daysOpen': '60',
      'activity': '낮음',
      'bodyScore': '3.2',
    },
  ];

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

  @override
  void didUpdateWidget(AnalysisFormAutofill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedServiceId != widget.selectedServiceId || 
        oldWidget.mastitisMode != widget.mastitisMode) {
      _controllers.clear();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    
    // 유방염 서비스인 경우 모드에 따라 필드 변경
    List<String> fields = selectedService.requiredFields;
    if (widget.selectedServiceId == 'mastitis_risk') {
      if (widget.mastitisMode == 'with_scc') {
        fields = ['체세포수 또는 생체지표'];
      } else {
        fields = ['전도율', '유지방비율', '체온', '활동량'];
      }
    }
    
    for (final field in fields) {
      final fieldInfo = _fieldMapping[field];
      if (fieldInfo != null) {
        _controllers[fieldInfo['key']] = TextEditingController();
      }
    }
  }

  void _loadCowData(String cowId) {
    final cow = _cowData.firstWhere((cow) => cow['id'] == cowId);
    setState(() {
      _controllers.forEach((key, controller) {
        if (cow.containsKey(key)) {
          controller.text = cow[key].toString();
        }
      });
    });
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _temperatureController.dispose();
    _milkVolumeController.dispose();
=======
    _controllers.values.forEach((controller) => controller.dispose());
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        const Text("🔍 소 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCowId,
          items: const [
            DropdownMenuItem(value: 'cow_1', child: Text('보균 소')),
            DropdownMenuItem(value: 'cow_2', child: Text('슬기 소')),
=======
        // 소 선택 섹션
        _buildCowSelectionSection(),
        const SizedBox(height: 24),

        // 데이터 입력 섹션
        _buildDataInputSection(),
        const SizedBox(height: 24),

        // 분석 버튼
        _buildAnalysisButton(),
      ],
    );
  }

  Widget _buildCowSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pets, color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              "소 선택",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")
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
<<<<<<< HEAD
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () {
              widget.onPredict(_temperatureController.text, _milkVolumeController.text);
            },
            child: const Text('예측하기'),
=======
          child: DropdownButtonFormField<String>(
            value: _selectedCowId,
            items: _cowData.map((cow) {
              return DropdownMenuItem<String>(
                value: cow['id'] as String,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        cow['name'][0],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cow['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '체중: ${cow['weight']}kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCowId = value;
                _loadCowData(value);
              });
            }
          },
          decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: '소를 선택하세요',
            ),
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")
          ),
        ),
      ],
    );
  }
<<<<<<< HEAD
}
=======

  Widget _buildDataInputSection() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    
    // 유방염 서비스인 경우 모드에 따라 필드 변경
    List<String> fields = selectedService.requiredFields;
    if (widget.selectedServiceId == 'mastitis_risk') {
      if (widget.mastitisMode == 'with_scc') {
        fields = ['체세포수 또는 생체지표'];
      } else {
        fields = ['전도율', '유지방비율', '체온', '활동량'];
      }
    }
    
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
          "${selectedService.label}에 필요한 데이터를 입력하세요",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        if (widget.selectedServiceId == 'mastitis_risk') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.mastitisMode == 'with_scc' 
                        ? '체세포수 데이터를 기반으로 정확한 위험도를 4단계로 분석합니다.'
                        : '다양한 생체 지표를 기반으로 염증 가능성을 3단계로 추정합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
>>>>>>> 542377f ("임시 커밋: feature/chatbot 브랜치 전환 전 작업 내용 저장")
