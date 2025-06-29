import 'package:flutter/material.dart';

class PregnancyCheckAddPage extends StatelessWidget {
  final String cowId;
  final String cowName;

  const PregnancyCheckAddPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cowName 임신감정 기록 추가'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('임신감정 기록 추가 페이지 (구현 예정)', style: TextStyle(fontSize: 16)),
      ),
    );
  }
} 