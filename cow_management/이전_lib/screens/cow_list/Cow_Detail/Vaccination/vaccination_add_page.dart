import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';
import 'package:cow_management/providers/DetailPage/Health/vaccination_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class VaccinationAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const VaccinationAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<VaccinationAddPage> createState() => _VaccinationAddPageState();
}

class _VaccinationAddPageState extends State<VaccinationAddPage> {
  final _formKey = GlobalKey<FormState>();

  // 컨트롤러들
  final _recordDateController = TextEditingController();
  final _vaccinationTimeController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _vaccineBatchController = TextEditingController();
  final _dosageController = TextEditingController();
  final _administratorController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _reactionDetailsController = TextEditingController();
  final _nextVaccinationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  // 상태 변수들
  String _vaccineType = '구제역';
  String _injectionSite = '목';
  String _injectionMethod = '근육주사';
  bool _adverseReaction = false;

  // 옵션들
  final List<String> _vaccineTypes = [
    '구제역', '브루셀라', '결핵', '럼피스킨', '광견병', '파상풍', '종합백신', '기타'
  ];
  final List<String> _injectionSites = [
    '목', '어깨', '엉덩이', '허벅지', '기타'
  ];
  final List<String> _injectionMethods = [
    '근육주사', '피하주사', '정맥주사', '경구투여', '기타'
  ];

  @override
  void initState() {
    super.initState();
    _recordDateController.text = DateTime.now().toString().split(' ')[0];
    // 기본 시간 문자열로 설정
    final now = TimeOfDay.now();
    _vaccinationTimeController.text = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _expiryDateController.text = DateTime.now().add(const Duration(days: 365)).toString().split(' ')[0];
    _nextVaccinationController.text = DateTime.now().add(const Duration(days: 365)).toString().split(' ')[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context가 완전히 초기화된 후에 올바른 형식으로 업데이트
    if (_vaccinationTimeController.text.contains(':') && _vaccinationTimeController.text.length == 5) {
      final time = TimeOfDay.now();
      _vaccinationTimeController.text = time.format(context);
    }
  }

  @override
  void dispose() {
    _recordDateController.dispose();
    _vaccinationTimeController.dispose();
    _vaccineNameController.dispose();
    _vaccineBatchController.dispose();
    _dosageController.dispose();
    _administratorController.dispose();
    _manufacturerController.dispose();
    _expiryDateController.dispose();
    _reactionDetailsController.dispose();
    _nextVaccinationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 백신접종 기록 추가'),
        backgroundColor: Colors.green,
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
              _buildVaccineInfoCard(),
              const SizedBox(height: 16),
              _buildInjectionInfoCard(),
              const SizedBox(height: 16),
              _buildReactionCard(),
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
            const Text('💉 기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _administratorController,
              decoration: const InputDecoration(
                labelText: '접종자',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value?.isEmpty == true ? '접종자를 입력해주세요' : null,
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
        labelText: '접종일 *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      validator: (value) => value?.isEmpty == true ? '접종일을 선택해주세요' : null,
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
      controller: _vaccinationTimeController,
      decoration: const InputDecoration(
        labelText: '접종 시간',
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
          _vaccinationTimeController.text = time.format(context);
        }
      },
    );
  }

  Widget _buildVaccineInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧪 백신 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vaccineNameController,
              decoration: const InputDecoration(
                labelText: '백신명 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
                hintText: '예: 구제역 백신',
              ),
              validator: (value) => value?.isEmpty == true ? '백신명을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdownField('백신 종류', _vaccineType, _vaccineTypes, (value) {
              setState(() => _vaccineType = value!);
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vaccineBatchController,
                    decoration: const InputDecoration(
                      labelText: '로트번호',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: '접종량 (ml)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                      hintText: '예: 2.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      labelText: '제조사',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: '유효기간',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 1095)),
                      );
                      if (date != null) {
                        _expiryDateController.text = date.toString().split(' ')[0];
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjectionInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 접종 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdownField('접종 부위', _injectionSite, _injectionSites, (value) {
              setState(() => _injectionSite = value!);
            }),
            const SizedBox(height: 16),
            _buildDropdownField('접종 방법', _injectionMethod, _injectionMethods, (value) {
              setState(() => _injectionMethod = value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ 부작용 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('부작용 발생 여부'),
              subtitle: Text(_adverseReaction ? '부작용이 발생했습니다' : '부작용이 없습니다'),
              value: _adverseReaction,
              onChanged: (value) => setState(() => _adverseReaction = value),
              activeColor: Colors.red,
            ),
            if (_adverseReaction) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _reactionDetailsController,
                decoration: const InputDecoration(
                  labelText: '부작용 상세 내용',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                  hintText: '부작용 증상을 상세히 기록하세요',
                ),
                maxLines: 3,
              ),
            ],
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nextVaccinationController,
                    decoration: const InputDecoration(
                      labelText: '다음 접종 예정일',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 1095)),
                      );
                      if (date != null) {
                        _nextVaccinationController.text = date.toString().split(' ')[0];
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: '비용 (원)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: '예: 15000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('백신접종 기록 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final token = Provider.of<UserProvider>(context, listen: false).accessToken;
        
        final record = VaccinationRecord(
          cowId: widget.cowId,
          recordDate: _recordDateController.text,
          vaccinationTime: _vaccinationTimeController.text,
          vaccineName: _vaccineNameController.text,
          vaccineType: _vaccineType,
          vaccineBatch: _vaccineBatchController.text.isEmpty ? '' : _vaccineBatchController.text,
          dosage: double.tryParse(_dosageController.text) ?? 0.0,
          injectionSite: _injectionSite,
          injectionMethod: _injectionMethod,
          administrator: _administratorController.text,
          vaccineManufacturer: _manufacturerController.text.isEmpty ? '' : _manufacturerController.text,
          expiryDate: _expiryDateController.text.isEmpty ? '' : _expiryDateController.text,
          adverseReaction: _adverseReaction,
          reactionDetails: _reactionDetailsController.text.isEmpty ? '' : _reactionDetailsController.text,
          nextVaccinationDue: _nextVaccinationController.text.isEmpty ? '' : _nextVaccinationController.text,
                     cost: int.tryParse(_costController.text),
          notes: _notesController.text.isEmpty ? '' : _notesController.text,
        );

        await Provider.of<VaccinationRecordProvider>(context, listen: false)
            .addRecord(record, token!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('백신접종 기록이 저장되었습니다'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
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
