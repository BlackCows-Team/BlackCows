import 'package:flutter/material.dart';

class CalvingRecordAddPage extends StatelessWidget {
  final String cowId;
  final String cowName;

  const CalvingRecordAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cowName 분만 기록 추가'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('분만 기록 추가 페이지 (구현 예정)', style: TextStyle(fontSize: 16)),
      ),
    );
  }
} 