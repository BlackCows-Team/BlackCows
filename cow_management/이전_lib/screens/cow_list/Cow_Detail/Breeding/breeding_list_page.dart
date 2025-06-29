import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/DetailPage/breeding_record_provider.dart';
import 'package:cow_management/models/Detail/breeding_record.dart';

class BreedingRecordListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const BreedingRecordListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<BreedingRecordListPage> createState() => _BreedingRecordListPageState();
}

class _BreedingRecordListPageState extends State<BreedingRecordListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final token = Provider.of<UserProvider>(context, listen: false).accessToken;
    await Provider.of<BreedingRecordProvider>(context, listen: false)
        .fetchRecords(widget.cowId, token!);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<BreedingRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 번식 기록 목록'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : records.isEmpty
              ? const Center(child: Text('등록된 기록이 없습니다.'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text(record.title),
                      subtitle: Text('번식일: ${record.breedingDate}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/breeding-record-detail',
                          arguments: {
                            'record': record,
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
