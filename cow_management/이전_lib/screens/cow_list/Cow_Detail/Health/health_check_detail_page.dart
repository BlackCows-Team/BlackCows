import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/health_check_record.dart';

class HealthCheckDetailPage extends StatelessWidget {
  final HealthCheckRecord record;

  const HealthCheckDetailPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] HealthCheckRecord: ${record.toJson()}');
    return Scaffold(
      appBar: AppBar(
        title: Text('건강검진 상세: ${record.recordDate}'),
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
                    '🏥 기본 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 검진 날짜', record.recordDate),
                  _buildInfoRow('⏰ 검진 시간', record.checkTime),
                  _buildInfoRow('👨‍⚕️ 검진자', record.examiner),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 생체 신호 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌡️ 생체 신호',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('🌡️ 체온', '${record.bodyTemperature}°C'),
                  _buildInfoRow('❤️ 심박수', '${record.heartRate}회/분'),
                  _buildInfoRow('💨 호흡수', '${record.respiratoryRate}회/분'),
                  _buildInfoRow(
                      '📊 체형점수(BCS)', record.bodyConditionScore.toString()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 신체 검사 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 신체 검사',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  if (record.udderCondition.isNotEmpty)
                    _buildInfoRow('🍼 유방 상태', record.udderCondition),
                  if (record.eyeCondition.isNotEmpty)
                    _buildInfoRow('👁️ 눈 상태', record.eyeCondition),
                  if (record.noseCondition.isNotEmpty)
                    _buildInfoRow('👃 코 상태', record.noseCondition),
                  if (record.coatCondition.isNotEmpty)
                    _buildInfoRow('🦌 털 상태', record.coatCondition),
                  if (record.hoofCondition.isNotEmpty)
                    _buildInfoRow('🦶 발굽 상태', record.hoofCondition),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 행동 평가 카드
          if (record.activityLevel.isNotEmpty || record.appetite.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎭 행동 평가',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    const SizedBox(height: 16),
                    if (record.activityLevel.isNotEmpty)
                      _buildInfoRow('🏃 활동 수준', record.activityLevel),
                    if (record.appetite.isNotEmpty)
                      _buildInfoRow('🍽️ 식욕 수준', record.appetite),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // 이상 증상 카드
          if (record.abnormalSymptoms.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ 이상 증상',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('🚨 증상', record.abnormalSymptoms.join(', ')),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // 추가 정보 카드
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
                  if (record.nextCheckDate.isNotEmpty)
                    _buildInfoRow('📅 다음 검진 예정일', record.nextCheckDate),
                  if (record.notes.isNotEmpty)
                    _buildInfoRow('📋 특이사항', record.notes),
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
          content: const Text('이 건강검진 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
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
