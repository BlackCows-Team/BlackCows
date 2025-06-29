import 'package:flutter/material.dart';
import 'package:cow_management/models/Detail/Health/treatment_record.model.dart';

class TreatmentDetailPage extends StatelessWidget {
  final TreatmentRecord record;

  const TreatmentDetailPage({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] 치료 상세 record: ${record.toJson()}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('치료 기록 상세'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('치료 기록 수정 기능은 준비 중입니다.')),
              );
            },
            tooltip: '수정',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
            tooltip: '삭제',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 정보 카드
            _buildInfoCard(
              '🩺 기본 정보',
              [
                _buildInfoRow('치료일', record.recordDate),
                if (record.treatmentTime != null)
                  _buildInfoRow('치료 시간', record.treatmentTime!),
                if (record.treatmentType != null)
                  _buildInfoRow('치료 유형', record.treatmentType!),
                if (record.diagnosis != null)
                  _buildInfoRow('진단명', record.diagnosis!),
              ],
            ),
            const SizedBox(height: 16),

            // 증상 정보 카드
            if (record.symptoms != null && record.symptoms!.isNotEmpty)
              _buildInfoCard(
                '🔍 증상',
                [
                  _buildInfoRow('관찰된 증상', record.symptoms!.join(', ')),
                ],
              ),
            if (record.symptoms != null && record.symptoms!.isNotEmpty)
              const SizedBox(height: 16),

            // 치료 정보 카드
            _buildInfoCard(
              '💊 치료 정보',
              [
                if (record.medicationUsed != null &&
                    record.medicationUsed!.isNotEmpty)
                  _buildInfoRow('사용 약물', record.medicationUsed!.join(', ')),
                if (record.dosageInfo != null && record.dosageInfo!.isNotEmpty)
                  ...record.dosageInfo!.entries.map(
                    (entry) => _buildInfoRow('${entry.key} 용량', entry.value),
                  ),
                if (record.treatmentMethod != null)
                  _buildInfoRow('치료 방법', record.treatmentMethod!),
                if (record.treatmentDuration != null)
                  _buildInfoRow('치료 기간', '${record.treatmentDuration}일'),
                if (record.withdrawalPeriod != null)
                  _buildInfoRow('휴약기간', '${record.withdrawalPeriod}일'),
              ],
            ),
            const SizedBox(height: 16),

            // 담당자 및 비용 정보 카드
            _buildInfoCard(
              '👨‍⚕️ 담당자 및 비용',
              [
                if (record.veterinarian != null)
                  _buildInfoRow('담당 수의사', record.veterinarian!),
                if (record.treatmentCost != null)
                  _buildInfoRow('치료 비용',
                      '${record.treatmentCost?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'),
              ],
            ),
            const SizedBox(height: 16),

            // 치료 결과 카드
            _buildInfoCard(
              '📊 치료 결과',
              [
                if (record.treatmentResponse != null)
                  _buildInfoRow('치료 반응', record.treatmentResponse!),
                if (record.sideEffects != null)
                  _buildInfoRow('부작용', record.sideEffects!),
                if (record.followUpRequired != null)
                  _buildInfoRow(
                      '추가 치료 필요', record.followUpRequired! ? '예' : '아니오'),
                if (record.followUpDate != null)
                  _buildInfoRow('추가 치료일', record.followUpDate!),
              ],
            ),
            const SizedBox(height: 16),

            // 메모 카드
            if (record.notes != null && record.notes!.isNotEmpty)
              _buildInfoCard(
                '📝 메모',
                [
                  _buildInfoRow('특이사항', record.notes!),
                ],
              ),
            if (record.notes != null && record.notes!.isNotEmpty)
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
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
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('치료 기록 삭제'),
          content: const Text('이 치료 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('치료 기록 삭제 기능은 준비 중입니다.')),
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
