import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/milking_record.dart';
import 'package:cow_management/providers/DetailPage/milking_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class MilkingRecordListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const MilkingRecordListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<MilkingRecordListPage> createState() => _MilkingRecordListPageState();
}

class _MilkingRecordListPageState extends State<MilkingRecordListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      await Provider.of<MilkingRecordProvider>(context, listen: false)
          .fetchRecords(widget.cowId, token!);
    } catch (e) {
      print('❌ 에러 발생: $e'); // 로그 찍기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('착유 기록을 불러오는 데 실패했어요')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<MilkingRecordProvider>(context).records;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 착유 기록'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : records.isEmpty
              ? const Center(child: Text('착유 기록이 없습니다'))
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text('🍼 ${record.recordDate}'),
                      subtitle: Text('생산량: ${record.milkYield}L'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/milking-record-detail',
                          arguments: {'recordId': record.id},
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/milking-record-add',
            arguments: {
              'cowId': widget.cowId,
              'cowName': widget.cowName,
            },
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
