import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/breeding_record.dart';
import 'package:cow_management/providers/DetailPage/breeding_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class BreedingRecordDetailPage extends StatefulWidget {
  final BreedingRecord record;

  const BreedingRecordDetailPage({super.key, required this.record});

  @override
  State<BreedingRecordDetailPage> createState() =>
      _BreedingRecordDetailPageState();
}

class _BreedingRecordDetailPageState extends State<BreedingRecordDetailPage> {
  late BreedingRecord _record;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _veterinarianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _titleController.text = _record.title;
    _descController.text = _record.description;
    _veterinarianController.text = _record.veterinarian;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('번식 기록 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isEditing ? _buildEditForm() : _buildDetailView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isEditing = !_isEditing),
        child: Icon(_isEditing ? Icons.cancel : Icons.edit),
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('제목', _record.title),
        _infoRow('설명', _record.description),
        _infoRow('번식일', _record.breedingDate),
        _infoRow('예상 분만일', _record.expectedCalvingDate),
        _infoRow('수의사', _record.veterinarian),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _buildField(_titleController, '제목'),
          _buildField(_descController, '설명'),
          _buildField(_veterinarianController, '수의사'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitEdit,
            child: const Text('수정 완료'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val == null || val.isEmpty ? '$label을 입력하세요' : null,
      ),
    );
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    final updated = BreedingRecord(
      id: _record.id,
      cowId: _record.cowId,
      recordType: _record.recordType,
      recordDate: _record.recordDate,
      title: _titleController.text,
      description: _descController.text,
      breedingMethod: _record.breedingMethod,
      breedingDate: _record.breedingDate,
      bullInfo: _record.bullInfo,
      expectedCalvingDate: _record.expectedCalvingDate,
      pregnancyCheckDate: _record.pregnancyCheckDate,
      breedingResult: _record.breedingResult,
      cost: _record.cost,
      veterinarian: _veterinarianController.text,
    );

    await Provider.of<BreedingRecordProvider>(context, listen: false)
        .updateRecord(_record.id, updated, token!);

    setState(() {
      _record = updated;
      _isEditing = false;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('수정 완료')));
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 이 기록을 삭제하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      await Provider.of<BreedingRecordProvider>(context, listen: false)
          .deleteRecord(_record.id, token!);

      if (context.mounted) {
        Navigator.pop(context); // 목록 페이지로 돌아가기
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('기록 삭제됨')));
      }
    }
  }
}
