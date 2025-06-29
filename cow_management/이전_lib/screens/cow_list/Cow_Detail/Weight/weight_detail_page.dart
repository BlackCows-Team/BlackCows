import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

class WeightDetailPage extends StatelessWidget {
  final WeightRecord record;

  const WeightDetailPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    print('📌 BCS 값: ${record.bodyConditionScore}');
    return Scaffold(
      appBar: AppBar(
        title: Text('체중측정 상세: ${record.recordDate}'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 기본 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚖️ 기본 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 측정 날짜', record.recordDate),
                  if (record.measurementTime != null)
                    _buildInfoRow('⏰ 측정 시간', record.measurementTime!),
                  if (record.measurer != null)
                    _buildInfoRow('👨‍⚕️ 측정자', record.measurer!),
                  if (record.measurementMethod != null)
                    _buildInfoRow('🔧 측정 방법', record.measurementMethod!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 측정 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📏 측정 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  if (record.weight != null)
                    _buildInfoRow('⚖️ 체중', '${record.weight}kg'),
                  if (record.heightWithers != null)
                    _buildInfoRow('📐 체고', '${record.heightWithers}cm'),
                  if (record.bodyLength != null)
                    _buildInfoRow('📏 체장', '${record.bodyLength}cm'),
                  if (record.chestGirth != null)
                    _buildInfoRow('📊 흉위', '${record.chestGirth}cm'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 체형 평가 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 체형 평가',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  if (record.bodyConditionScore != null)
                    _buildInfoRow(
                        '📊 체형점수(BCS)', record.bodyConditionScore.toString()),
                  if (record.weightCategory != null)
                    _buildInfoRow('📈 체중 분류', record.weightCategory!),
                  if (record.growthRate != null)
                    _buildInfoRow('📈 증체율', '${record.growthRate}%'),
                  if (record.targetWeight != null)
                    _buildInfoRow('🎯 목표 체중', '${record.targetWeight}kg'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 추가 정보 카드
          if (record.notes != null && record.notes!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 추가 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('📋 특이사항', record.notes!),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // 수정/삭제 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('수정 기능은 준비 중입니다')),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmDialog(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('삭제'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 체중측정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제 기능은 준비 중입니다')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
