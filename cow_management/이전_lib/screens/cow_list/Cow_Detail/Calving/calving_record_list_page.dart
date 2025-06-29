import 'package:flutter/material.dart';

class CalvingRecordListPage extends StatelessWidget {
  final String cowId;
  final String cowName;

  const CalvingRecordListPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cowName 분만 기록'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('분만 기록 목록 페이지 (구현 예정)', style: TextStyle(fontSize: 16)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/calving-record/add',
            arguments: {
              'cowId': cowId,
              'cowName': cowName,
            },
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 