import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/DetailPage/Health/health_check_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';
import 'package:cow_management/screens/cow_list/Cow_Detail/Health/health_check_detail_page.dart';

class HealthCheckListPage extends StatefulWidget {
  final String cowId;
  final String cowName;

  const HealthCheckListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<HealthCheckListPage> createState() => _HealthCheckListPageState();
}

class _HealthCheckListPageState extends State<HealthCheckListPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken;
      await Provider.of<HealthCheckProvider>(context, listen: false)
          .fetchRecords(widget.cowId, token!);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '서버에서 데이터를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cowName} - 건강검진 목록'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/health-check/add',
            arguments: {
              'cowId': widget.cowId,
              'cowName': widget.cowName,
            },
          ).then((_) => _loadRecords()); // 추가 후 목록 새로고침
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('건강검진 기록을 불러오는 중...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final records = Provider.of<HealthCheckProvider>(context).records;

    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '건강검진 기록이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '아래 + 버튼을 눌러 첫 기록을 추가해보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];

          // 메모가 없으면 기본 텍스트 표시
          final String notesText = record.notes.isNotEmpty == true
              ? (record.notes.length > 20
                  ? '${record.notes.substring(0, 20)}...'
                  : record.notes)
              : '메모 없음';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF4CAF50),
                child: Icon(Icons.monitor_heart, color: Colors.white),
              ),
              title: Text(
                record.recordDate,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  notesText,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF4CAF50)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthCheckDetailPage(record: record),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
