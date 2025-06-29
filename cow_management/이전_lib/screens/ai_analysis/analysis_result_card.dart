import 'package:flutter/material.dart';

class AnalysisResultCard extends StatelessWidget {
  const AnalysisResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ 너비 전체로!
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📈 예측 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('예상 착유량: 18.2L', style: TextStyle(fontSize: 16)),
          Text('정확도: 91%', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Text('➡️ 조치 권장사항: 하루 두 번 착유를 유지하고 사료 섭취량을 체크하세요.'),
        ],
      ),
    );
  }
}
