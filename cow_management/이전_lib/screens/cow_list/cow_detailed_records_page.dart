import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cow.name} 상세 기록'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.health_and_safety, color: Colors.white), text: '건강 정보'),
            Tab(icon: Icon(Icons.pregnant_woman, color: Colors.white), text: '번식 정보'),
            Tab(icon: Icon(Icons.rice_bowl, color: Colors.white), text: '사료 정보'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthTab(),
          _buildBreedingTab(),
          _buildFeedingTab(),
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
            onViewPressed: () => _navigateToList('/health-check/list'),
            onAddPressed: () => _navigateToAdd('/health-check/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '백신접종 기록',
            icon: Icons.vaccines,
            color: Colors.green,
            emoji: '💉',
            description: '백신 접종 일정 및 이력 관리',
            onViewPressed: () => _navigateToList('/vaccination/list'),
            onAddPressed: () => _navigateToAdd('/vaccination/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '체중측정 기록',
            icon: Icons.monitor_weight,
            color: Colors.orange,
            emoji: '⚖️',
            description: '체중 변화 추이 및 성장 기록',
            onViewPressed: () => _navigateToList('/weight/list'),
            onAddPressed: () => _navigateToAdd('/weight/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '치료 기록',
            icon: Icons.medical_services,
            color: Colors.red,
            emoji: '🩺',
            description: '질병 치료 및 처방 기록',
            onViewPressed: () => _navigateToList('/treatment/list'),
            onAddPressed: () => _navigateToAdd('/treatment/add'),
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
            onViewPressed: () => _navigateToList('/estrus-record/list'),
            onAddPressed: () => _navigateToAdd('/estrus-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '인공수정 기록',
            icon: Icons.medical_services_outlined,
            color: Colors.blue,
            emoji: '🎯',
            description: '인공수정 실시 및 결과 기록',
            onViewPressed: () => _navigateToList('/insemination-record/list'),
            onAddPressed: () => _navigateToAdd('/insemination-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '임신감정 기록',
            icon: Icons.search,
            color: Colors.purple,
            emoji: '🤱',
            description: '임신 확인 및 감정 결과',
            onViewPressed: () => _navigateToList('/pregnancy-check/list'),
            onAddPressed: () => _navigateToAdd('/pregnancy-check/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '분만 기록',
            icon: Icons.child_care,
            color: Colors.teal,
            emoji: '👶',
            description: '분만 과정 및 송아지 정보',
            onViewPressed: () => _navigateToList('/calving-record/list'),
            onAddPressed: () => _navigateToAdd('/calving-record/add'),
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
            onViewPressed: () => _navigateToList('/feeding-record/list'),
            onAddPressed: () => _navigateToAdd('/feeding-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '착유 기록',
            icon: Icons.local_drink,
            color: Colors.indigo,
            emoji: '🥛',
            description: '착유량, 유성분 및 품질 기록',
            onViewPressed: () => _navigateToList('/milking-records'),
            onAddPressed: () => _navigateToAdd('/milking-record-add'),
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewPressed,
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('기록 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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