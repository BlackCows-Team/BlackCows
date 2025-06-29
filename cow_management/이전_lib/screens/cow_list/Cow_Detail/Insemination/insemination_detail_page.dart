import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';
import 'package:cow_management/providers/DetailPage/Reproduction/insemination_record_provider.dart';
import 'package:cow_management/providers/user_provider.dart';

class InseminationDetailPage extends StatefulWidget {
  final InseminationRecord record;
  final String cowId;
  final String cowName;

  const InseminationDetailPage({
    super.key,
    required this.record,
    required this.cowId,
    required this.cowName,
  });

  @override
  State<InseminationDetailPage> createState() => _InseminationDetailPageState();
}

class _InseminationDetailPageState extends State<InseminationDetailPage> {
  @override
  Widget build(BuildContext context) {
    print('✅ 성공확률: ${widget.record.successProbability}');
    print('✅ 임신감정 예정일: ${widget.record.pregnancyCheckScheduled}');
    print('✅ 비용: ${widget.record.cost}');
    return Scaffold(
      appBar: AppBar(
        title: Text('인공수정 상세: ${widget.record.recordDate}'),
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
                    '🎯 기본 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('📅 수정 날짜', widget.record.recordDate),
                  if (widget.record.inseminationTime != null &&
                      widget.record.inseminationTime!.isNotEmpty)
                    _buildInfoRow('⏰ 수정 시간', widget.record.inseminationTime!),
                  if (widget.record.technicianName != null &&
                      widget.record.technicianName!.isNotEmpty)
                    _buildInfoRow('👨‍⚕️ 수의사', widget.record.technicianName!),
                  if (widget.record.inseminationMethod != null &&
                      widget.record.inseminationMethod!.isNotEmpty)
                    _buildInfoRow(
                        '🔧 수정 방법', widget.record.inseminationMethod!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 종축 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🐂 종축 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown),
                  ),
                  const SizedBox(height: 16),
                  if (widget.record.bullBreed != null &&
                      widget.record.bullBreed!.isNotEmpty)
                    _buildInfoRow('🐂 종축 정보', widget.record.bullBreed!),
                  if (widget.record.semenQuality != null &&
                      widget.record.semenQuality!.isNotEmpty)
                    _buildInfoRow('💧 정액 품질', widget.record.semenQuality!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 결과 정보 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 결과 정보',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  if (widget.record.successProbability != null)
                    _buildInfoRow(
                      '📈 성공 확률',
                      '${widget.record.successProbability!.toStringAsFixed(1)}%',
                    ),
                  if (widget.record.pregnancyCheckScheduled != null &&
                      widget.record.pregnancyCheckScheduled!.isNotEmpty)
                    _buildInfoRow(
                        '📅 분만 예정일', widget.record.pregnancyCheckScheduled!),
                  if (widget.record.cost != null)
                    _buildInfoRow(
                        '💰 비용', '${widget.record.cost?.toStringAsFixed(0)}원'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 추가 정보 카드
          if (widget.record.notes != null && widget.record.notes!.isNotEmpty)
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
                    _buildInfoRow('📋 특이사항', widget.record.notes!),
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
                  onPressed: () => _showDeleteConfirmDialog(),
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

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🗑️ 기록 삭제'),
          content: const Text('이 인공수정 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord() async {
    if (widget.record.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('삭제할 수 없는 기록입니다'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final token =
          Provider.of<UserProvider>(context, listen: false).accessToken!;
      final provider =
          Provider.of<InseminationRecordProvider>(context, listen: false);
      final success = await provider.deleteRecord(widget.record.id!, token);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('인공수정 기록이 삭제되었습니다'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // 상세 페이지 닫기
        Navigator.of(context).pop(); // 목록 페이지로 돌아가기
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('기록 삭제에 실패했습니다'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('오류가 발생했습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
