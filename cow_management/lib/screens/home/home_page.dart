import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int countByStatus(List cows, String status) {
    return cows.where((cow) => cow.status == status).length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.shouldShowWelcome && userProvider.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${userProvider.currentUser!.username}님 환영합니다!'), // 사용자 이름/실명으로 환영
            backgroundColor: Colors.pink,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // 환영 메시지 표시 후 플래그 리셋
        userProvider.markWelcomeShown();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCowStatusChartCard(),
              _buildAIPredictionSummary(),
              _buildFavoriteCows(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/cow.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 36);
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '소담소담',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              
              // 사용자 정보 표시
              if (user != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.pink.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '${user.username}님', // 사용자 이름/실명
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.pink.shade600,
                        ),
                      ),
                      if (user.farmNickname != null && user.farmNickname!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 12,
                          color: Colors.pink.shade300,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.home, size: 16, color: Colors.pink.shade600),
                        const SizedBox(width: 4),
                        Text(
                          user.farmNickname!, // 목장 별명
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCowStatusChartCard() {
    final cowProvider = Provider.of<CowProvider>(context);
    final cows = cowProvider.cows;

    final int normal = countByStatus(cows, '양호');
    final int warning = countByStatus(cows, '위험');
    final int danger = countByStatus(cows, '이상');

    final statusSummary = [
      {'label': '양호', 'count': normal, 'color': Colors.green},
      {'label': '위험', 'count': warning, 'color': Colors.orange},
      {'label': '이상', 'count': danger, 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '소 상태 요약',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: statusSummary.map((item) {
                return Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${item['count']}두',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPredictionSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 도넛 느낌 퍼센트
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.78, // 78% 정상
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.pink,
                  ),
                ),
                const Text(
                  '78%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // 텍스트 정보
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 예측 결과',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.search, size: 18, color: Colors.black87),
                      SizedBox(width: 6),
                      Text('의심 소: 1두 (C384)', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Colors.green),
                      SizedBox(width: 6),
                      Text('정상: 78%', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18, color: Colors.orange),
                      SizedBox(width: 6),
                      Text('주의: 3두', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCows(BuildContext context) {
    final cowProvider = Provider.of<CowProvider>(context);
    final favorites = cowProvider.favorites;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '즐겨찾는 소',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (favorites.isEmpty)
            const Text('즐겨찾기한 소가 없어요!')
          else
            ...favorites.map((cow) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/cows/detail', arguments: cow);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          cow.isFavorite ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          cowProvider.toggleFavorite(cow);
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cow.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '품종: ${cow.breed}, 상태: ${cow.status}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/cows');
              },
              child: const Text(
                '나의 소 목록 불러오기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}