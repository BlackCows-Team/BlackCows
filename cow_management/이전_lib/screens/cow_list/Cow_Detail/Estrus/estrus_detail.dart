import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';

class EstrusDetailPage extends StatelessWidget {
  final EstrusRecord record;

  const EstrusDetailPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('발정 기록 상세: ${record.recordDate}'),
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
                    '💕 기본 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 발정 날짜', record.recordDate),
                  if (record.estrusStartTime != null && record.estrusStartTime!.isNotEmpty)
                    _buildInfoRow('⏰ 발정 시간', record.estrusStartTime!),
                  if (record.detectedBy != null && record.detectedBy!.isNotEmpty)
                    _buildInfoRow('👨‍🌾 발견자', record.detectedBy!),
                  if (record.detectionMethod != null && record.detectionMethod!.isNotEmpty)
                    _buildInfoRow('🔍 발견 방법', record.detectionMethod!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 발정 특성 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌡️ 발정 특성',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  if (record.estrusIntensity != null && record.estrusIntensity!.isNotEmpty)
                    _buildInfoRow('🔥 발정 강도', record.estrusIntensity!),
                  if (record.estrusDuration != null && record.estrusDuration! > 0)
                    _buildInfoRow('⏱️ 지속 시간', '${record.estrusDuration}시간'),
                  if (record.behaviorSigns != null && record.behaviorSigns!.isNotEmpty)
                    _buildInfoRow('🎭 행동 징후', record.behaviorSigns!.join(', ')),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 생리적 징후 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔬 생리적 징후',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  if (record.visualSigns != null && record.visualSigns!.isNotEmpty)
                    _buildInfoRow('👁️ 육안 관찰', record.visualSigns!.join(', ')),
                  if (record.nextExpectedEstrus != null && record.nextExpectedEstrus!.isNotEmpty)
                    _buildInfoRow('📅 다음 발정 예상일', record.nextExpectedEstrus!),
                  if (record.breedingPlanned != null)
                    _buildInfoRow('🎯 교배 계획', record.breedingPlanned! ? '예정됨' : '없음'),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
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
          content: const Text('이 발정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
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
