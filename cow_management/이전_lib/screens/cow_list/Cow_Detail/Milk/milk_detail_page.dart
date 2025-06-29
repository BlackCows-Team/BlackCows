import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/providers/user_provider.dart';

class MilkingRecordDetailPage extends StatefulWidget {
  const MilkingRecordDetailPage({super.key});

  @override
  State<MilkingRecordDetailPage> createState() => _MilkingRecordDetailPageState();
}

class _MilkingRecordDetailPageState extends State<MilkingRecordDetailPage> {
  Map<String, dynamic>? recordDetail;
  bool isLoading = true;
  String? errorMessage;
  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      _loadRecordDetail();
    }
  }

  Future<void> _loadRecordDetail() async {
    try {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final String recordId = arguments['recordId'] as String;
      
      final token = Provider.of<UserProvider>(context, listen: false).accessToken;
      final baseUrl = dotenv.env['API_BASE_URL'];
      
      if (token == null || baseUrl == null) {
        throw Exception('인증 정보가 없습니다');
      }

      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          recordDetail = response.data;
          isLoading = false;
        });
      } else {
        throw Exception('기록을 불러올 수 없습니다');
      }
    } catch (e) {
      setState(() {
        errorMessage = '상세 정보를 불러오는데 실패했습니다: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('착유 상세'),
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('착유 상세'),
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final recordData = recordDetail?['record_data'] ?? {};
    final recordDate = recordDetail?['record_date'] ?? '알 수 없음';

    return Scaffold(
      appBar: AppBar(
        title: Text('착유 상세: $recordDate'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📅 날짜: $recordDate', 
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 기본 정보
                  if (recordData['milk_yield'] != null) 
                    _buildInfoRow('🥛 생산량', '${recordData['milk_yield']}L'),
                  
                  if (recordData['milking_session'] != null && recordData['milking_session'] > 0) 
                    _buildInfoRow('🔄 착유 회차', '${recordData['milking_session']}회차'),
                  
                  // 시간 정보
                  if (recordData['milking_start_time'] != null && recordData['milking_start_time'].toString().isNotEmpty) 
                    _buildInfoRow('⏰ 시작 시간', recordData['milking_start_time'].toString()),
                  
                  if (recordData['milking_end_time'] != null && recordData['milking_end_time'].toString().isNotEmpty) 
                    _buildInfoRow('⏰ 종료 시간', recordData['milking_end_time'].toString()),
                  
                  // 유성분 정보
                  if (recordData['fat_percentage'] != null && recordData['fat_percentage'] > 0) 
                    _buildInfoRow('🧈 유지방', '${recordData['fat_percentage']}%'),
                  
                  if (recordData['protein_percentage'] != null && recordData['protein_percentage'] > 0) 
                    _buildInfoRow('🍗 단백질', '${recordData['protein_percentage']}%'),
                  
                  // 품질 측정 정보
                  if (recordData['conductivity'] != null && recordData['conductivity'] > 0) 
                    _buildInfoRow('📊 전도도', recordData['conductivity'].toString()),
                  
                  if (recordData['somatic_cell_count'] != null && recordData['somatic_cell_count'] > 0) 
                    _buildInfoRow('🧬 체세포수', recordData['somatic_cell_count'].toString()),
                  
                  if (recordData['temperature'] != null && recordData['temperature'] > 0) 
                    _buildInfoRow('🌡️ 온도', '${recordData['temperature']}°C'),
                  
                  if (recordData['color_value'] != null && recordData['color_value'].toString().isNotEmpty) 
                    _buildInfoRow('🎨 색상', recordData['color_value'].toString()),
                  
                  // 기타 정보
                  if (recordData['blood_flow_detected'] != null) 
                    _buildInfoRow('🩸 혈류 감지', recordData['blood_flow_detected'] ? '예' : '아니오'),
                  
                  if (recordData['notes'] != null && recordData['notes'].toString().isNotEmpty) 
                    _buildInfoRow('📝 비고', recordData['notes'].toString()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 수정 페이지로 이동
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('수정 기능은 준비 중입니다')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('수정'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // TODO: 삭제 확인 후 삭제 로직
                    _showDeleteConfirmDialog();
                  },
                  child: const Text('삭제'),
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
            width: 120,
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
          title: const Text('기록 삭제'),
          content: const Text('이 착유 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 실제 삭제 로직 구현
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
