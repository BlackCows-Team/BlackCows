import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CowDetailedRecordsPage extends StatefulWidget {
  final Cow cow;

  const CowDetailedRecordsPage({
    super.key,
    required this.cow,
  });

  @override
  State<CowDetailedRecordsPage> createState() => _CowDetailedRecordsPageState();
}

class _CowDetailedRecordsPageState extends State<CowDetailedRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _detailedRecords = [];
  bool _isLoading = false;
  late String _baseUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    _fetchDetailedRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetailedRecords() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = '$_baseUrl/records/cow/${widget.cow.id}/all-records';
      print('🔄 상세기록 조회 시작: $url');
      print('🐮 젖소 ID: ${widget.cow.id}');
      print('🪪 토큰: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('✅ 응답 상태 코드: ${response.statusCode}');
      print('📄 응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // 응답이 리스트인지 객체인지 확인
            if (data is List) {
              _detailedRecords = data;
            } else if (data is Map && data['records'] != null) {
              _detailedRecords = data['records'];
            } else {
              _detailedRecords = [];
            }
            _isLoading = false;
          });
          print('📊 로드된 기록 수: ${_detailedRecords.length}');
        }
      } else if (response.statusCode == 404) {
        // 기록이 없는 경우
        if (mounted) {
          setState(() {
            _detailedRecords = [];
            _isLoading = false;
          });
          print('📭 해당 젖소의 기록이 없습니다.');
        }
      } else {
        throw Exception('기록을 불러오는데 실패했습니다. 상태코드: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detailedRecords = [];
          _isLoading = false;
        });
        print('❌ 상세기록 조회 오류: $e');
      }
    }
  }

  Future<void> _updateRecord(String recordId, Map<String, dynamic> updateData) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/records/$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 목록 새로고침
        await _fetchDetailedRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 성공적으로 수정되었습니다.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        throw Exception('기록 수정에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/records/$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 성공적으로 삭제된 경우 목록 새로고침
        await _fetchDetailedRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 성공적으로 삭제되었습니다.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        throw Exception('기록 삭제에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: ModernAppBar(
        title: '${widget.cow.name} 상세 기록',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4CAF50),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF4CAF50),
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.health_and_safety), text: '건강'),
                Tab(icon: Icon(Icons.pregnant_woman), text: '번식'),
                Tab(icon: Icon(Icons.rice_bowl), text: '사료/착유'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const ModernLoadingWidget(message: '기록을 불러오는 중...')
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHealthTab(),
                      _buildBreedingTab(),
                      _buildFeedingTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '건강검진 기록',
            icon: Icons.health_and_safety,
            color: Colors.blue,
            emoji: '🏥',
            description: '정기 건강검진 및 체크업 기록',
            onViewPressed: () => _navigateToList('/health-check-records'),
            onAddPressed: () => _navigateToAdd('/health-check/add'),
            recordType: 'health-check',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '백신접종 기록',
            icon: Icons.vaccines,
            color: Colors.green,
            emoji: '💉',
            description: '백신 접종 일정 및 이력 관리',
            onViewPressed: () => _navigateToList('/vaccination-records'),
            onAddPressed: () => _navigateToAdd('/vaccination/add'),
            recordType: 'vaccination',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '체중측정 기록',
            icon: Icons.monitor_weight,
            color: Colors.orange,
            emoji: '⚖️',
            description: '체중 변화 추이 및 성장 기록',
            onViewPressed: () => _navigateToList('/weight-records'),
            onAddPressed: () => _navigateToAdd('/weight-record/add'),
            recordType: 'weight',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '치료 기록',
            icon: Icons.medical_services,
            color: Colors.red,
            emoji: '🩺',
            description: '질병 치료 및 처방 기록',
            onViewPressed: () => _navigateToList('/treatment-records'),
            onAddPressed: () => _navigateToAdd('/treatment/add'),
            recordType: 'treatment',
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '발정 기록',
            icon: Icons.waves,
            color: Colors.pink,
            emoji: '💕',
            description: '발정 주기 및 행동 관찰 기록',
            onViewPressed: () => _navigateToList('/breeding-records'),
            onAddPressed: () => _navigateToAdd('/estrus/add'),
            recordType: 'estrus',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '인공수정 기록',
            icon: Icons.medical_services_outlined,
            color: Colors.blue,
            emoji: '🎯',
            description: '인공수정 실시 및 결과 기록',
            onViewPressed: () => _navigateToList('/breeding-records'),
            onAddPressed: () => _navigateToAdd('/insemination/add'),
            recordType: 'insemination',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '임신감정 기록',
            icon: Icons.search,
            color: Colors.purple,
            emoji: '🤱',
            description: '임신 확인 및 감정 결과',
            onViewPressed: () => _navigateToList('/breeding-records'),
            onAddPressed: () => _navigateToAdd('/pregnancy-check/add'),
            recordType: 'pregnancy-check',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '분만 기록',
            icon: Icons.child_care,
            color: Colors.teal,
            emoji: '👶',
            description: '분만 과정 및 송아지 정보',
            onViewPressed: () => _navigateToList('/breeding-records'),
            onAddPressed: () => _navigateToAdd('/breeding/add'),
            recordType: 'calving',
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '사료급여 기록',
            icon: Icons.rice_bowl,
            color: Colors.brown,
            emoji: '🌾',
            description: '사료 종류, 급여량 및 시간 기록',
            onViewPressed: () => _navigateToList('/feeding-records'),
            onAddPressed: () => _navigateToAdd('/feeding-record/add'),
            recordType: 'feed',
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '착유 기록',
            icon: Icons.local_drink,
            color: Colors.indigo,
            emoji: '🥛',
            description: '착유량, 유성분 및 품질 기록',
            onViewPressed: () => _navigateToList('/milking-records'),
            onAddPressed: () => _navigateToAdd('/milking-record/add'),
            recordType: 'milking',
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required IconData icon,
    required Color color,
    required String emoji,
    required String description,
    required VoidCallback onViewPressed,
    required VoidCallback onAddPressed,
    required String recordType,
  }) {
    // 해당 타입의 기록들을 필터링
    final typeRecords = _detailedRecords.where((record) => 
        record['record_type'] == recordType).toList();
    final recordCount = typeRecords.length;
    
    return ModernCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$recordCount개',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordsList(recordType, title, color, typeRecords),
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('기록 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('기록 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordsList(String recordType, String title, Color color, List<dynamic> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child:               records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '등록된 기록이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _buildRecordItem(record, color);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record, Color color) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record['title'] ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRecordDialog(record);
                    } else if (value == 'delete') {
                      _showDeleteRecordDialog(record);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          const Text('수정'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Text('삭제', style: TextStyle(color: Colors.red.shade400)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (record['description'] != null)
              Text(
                record['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  record['record_date'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRecordTypeDisplayName(record['record_type']),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRecordTypeDisplayName(String recordType) {
    switch (recordType) {
      case 'milking':
        return '착유';
      case 'health-check':
        return '건강검진';
      case 'vaccination':
        return '백신접종';
      case 'weight':
        return '체중측정';
      case 'treatment':
        return '치료';
      case 'estrus':
        return '발정';
      case 'insemination':
        return '인공수정';
      case 'pregnancy-check':
        return '임신감정';
      case 'calving':
        return '분만';
      case 'feed':
        return '사료급여';
      default:
        return recordType;
    }
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    final titleController = TextEditingController(text: record['title'] ?? '');
    final descriptionController = TextEditingController(text: record['description'] ?? '');
    final dateController = TextEditingController(text: record['record_date'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text('기록 수정'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                label: '제목',
                controller: titleController,
                hint: '기록 제목을 입력하세요',
              ),
              const SizedBox(height: 16),
              ModernTextField(
                label: '날짜',
                controller: dateController,
                hint: 'YYYY-MM-DD',
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              ModernTextField(
                label: '설명',
                controller: descriptionController,
                hint: '기록에 대한 설명을 입력하세요',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기록 유형: ${_getRecordTypeDisplayName(record['record_type'])}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '생성일: ${record['created_at'] ?? '알 수 없음'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('제목을 입력해주세요.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final updateData = {
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                if (dateController.text.trim().isNotEmpty)
                  'record_date': dateController.text.trim(),
              };
              
              Navigator.pop(context);
              await _updateRecord(record['id'], updateData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRecordDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('기록 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '다음 기록을 삭제하시겠습니까?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['title'] ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '유형: ${_getRecordTypeDisplayName(record['record_type'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '날짜: ${record['record_date'] ?? '알 수 없음'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '삭제된 기록은 복구할 수 없습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRecord(record['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _navigateToList(String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'cowId': widget.cow.id,
        'cowName': widget.cow.name,
      },
    );
  }

  void _navigateToAdd(String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'cowId': widget.cow.id,
        'cowName': widget.cow.name,
      },
    );
  }
} 