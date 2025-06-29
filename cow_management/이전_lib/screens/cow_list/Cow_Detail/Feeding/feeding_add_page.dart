import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';
import 'package:cow_management/providers/DetailPage/feeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class FeedingRecordAddPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const FeedingRecordAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<FeedingRecordAddPage> createState() => _FeedingRecordAddPageState();
}

class _FeedingRecordAddPageState extends State<FeedingRecordAddPage> {
  final _formKey = GlobalKey<FormState>();
  
  // 컨트롤러들
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _amountController = TextEditingController();
  final _nutritionController = TextEditingController();
  final _supplementController = TextEditingController();
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  final _noteController = TextEditingController();

  // 상태 변수들
  String _feedType = '배합사료';
  String _feedingMethod = '자동급이';
  String _qualityGrade = '특급';

  // 옵션들
  final List<String> _feedTypes = [
    '배합사료', '조사료', '건초', '사일리지', '농후사료', '단미사료', '첨가제', '기타'
  ];
  final List<String> _feedingMethods = [
    '자동급이', '수동급이', 'TMR급이', '방목', '기타'
  ];
  final List<String> _qualityGrades = [
    '특급', '1급', '2급', '3급', '등외'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
    final now = TimeOfDay.now();
    _timeController.text = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeController.text.contains(':') && _timeController.text.length == 5) {
      final time = TimeOfDay.now();
      _timeController.text = time.format(context);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _amountController.dispose();
    _nutritionController.dispose();
    _supplementController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} 사료급여 기록 추가'),
        backgroundColor: Colors.orange,
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
              _buildFeedInfoCard(),
              const SizedBox(height: 16),
              _buildNutritionCard(),
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
            const Text('🌾 기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeField(),
            const SizedBox(height: 16),
            _buildDropdownField('급여 방법', _feedingMethod, _feedingMethods, (value) {
              setState(() => _feedingMethod = value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: '급여일 *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      validator: (value) => value?.isEmpty == true ? '급여일을 선택해주세요' : null,
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
        labelText: '급여 시간',
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

  Widget _buildFeedInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🥗 사료 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDropdownField('사료 종류', _feedType, _feedTypes, (value) {
              setState(() => _feedType = value!);
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '급여량 (kg) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      hintText: '예: 25.5',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => value?.isEmpty == true ? '급여량을 입력해주세요' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdownField('품질 등급', _qualityGrade, _qualityGrades, (value) {
                    setState(() => _qualityGrade = value!);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _supplierController,
                    decoration: const InputDecoration(
                      labelText: '공급업체',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
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
                      hintText: '예: 45000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧪 영양 성분', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nutritionController,
              decoration: const InputDecoration(
                labelText: '영양 성분 정보',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
                hintText: '예: 조단백질 16%, 조지방 3%, 조섬유 12%',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplementController,
              decoration: const InputDecoration(
                labelText: '첨가제 및 보조사료',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_circle),
                hintText: '예: 비타민, 미네랄, 프로바이오틱스',
              ),
              maxLines: 2,
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
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '특이사항 및 메모',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: '사료 상태, 기호성, 잔량 등을 기록하세요',
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
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('사료급여 기록 저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final feedingProvider = Provider.of<FeedingRecordProvider>(context, listen: false);

        final record = FeedingRecord(
          id: '',
          cowId: widget.cowId,
          feedingDate: _dateController.text,
          feedTime: _timeController.text,
          feedType: _feedType,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          notes: _noteController.text.isEmpty ? '' : _noteController.text,
        );

        final success = await feedingProvider.addRecord(record, userProvider.accessToken!);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사료급여 기록이 저장되었습니다'), backgroundColor: Colors.green),
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
