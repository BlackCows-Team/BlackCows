import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/vaccination_record.dart';

class VaccinationDetailPage extends StatelessWidget {
  final VaccinationRecord record;

  const VaccinationDetailPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('백신접종 상세: ${record.recordDate}'),
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
                    '💉 기본 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 접종 날짜', record.recordDate),
                  if (record.vaccinationTime != null)
                    _buildInfoRow('⏰ 접종 시간', record.vaccinationTime!),
                  if (record.administrator != null)
                    _buildInfoRow('👨‍⚕️ 접종자', record.administrator!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 백신 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧪 백신 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  if (record.vaccineName != null)
                    _buildInfoRow('💊 백신명', record.vaccineName!),
                  if (record.vaccineType != null)
                    _buildInfoRow('🔬 백신 종류', record.vaccineType!),
                  if (record.vaccineManufacturer != null)
                    _buildInfoRow('🏭 제조사', record.vaccineManufacturer!),
                  if (record.vaccineBatch != null)
                    _buildInfoRow('📦 배치번호', record.vaccineBatch!),
                  if (record.expiryDate != null)
                    _buildInfoRow('📅 유효기간', record.expiryDate!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 접종 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 접종 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  if (record.dosage != null)
                    _buildInfoRow('💧 접종량', '${record.dosage}ml'),
                  if (record.injectionSite != null)
                    _buildInfoRow('📍 접종 부위', record.injectionSite!),
                  if (record.injectionMethod != null)
                    _buildInfoRow('🔧 접종 방법', record.injectionMethod!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 부작용 정보 카드
          if (record.adverseReaction != null || record.reactionDetails != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ 부작용 정보',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    if (record.adverseReaction != null)
                      _buildInfoRow('🚨 부작용 발생', record.adverseReaction! ? '예' : '아니오'),
                    if (record.reactionDetails != null && record.reactionDetails!.isNotEmpty)
                      _buildInfoRow('📝 부작용 상세', record.reactionDetails!),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  const SizedBox(height: 16),
                  if (record.nextVaccinationDue != null)
                    _buildInfoRow('📅 다음 접종 예정일', record.nextVaccinationDue!),
                  if (record.cost != null)
                    _buildInfoRow('💰 비용', '${record.cost?.toStringAsFixed(0)}원'),
                  if (record.notes != null && record.notes!.isNotEmpty)
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
          content: const Text('이 백신접종 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
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
