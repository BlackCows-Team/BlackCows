import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "소담소담이란?",
      subtitle: "AI 기반 낙농 젖소 전문 관리",
      description: "인공지능(AI) 기술을 기반으로 개발된 낙농 젖소 전문 관리 애플리케이션입니다.\n\n기존 범용 축산 관리 서비스와 달리 젖소 특화 기능을 제공하여, 낙농 농가의 효율성과 생산성 향상을 지원합니다.",
      image: Image.asset('assets/images/app_icon.png', width: 120, height: 120, fit: BoxFit.contain),
      color: Color(0xFF4CAF50),
    ),
    OnboardingData(
      title: "핵심 기능",
      subtitle: "스마트한 목장 관리",
      description: "📝 목장 기록 관리\n젖소의 건강, 번식, 착유, 사료 기록을 쉽고 편리하게 관리\n\n💬 챗봇 시스템\n24시간 언제든지 궁금한 점을 질문하고 실시간 답변 제공\n\n🔮 AI 예측 서비스\n유방염 예측, 착유량 예측, 번식 최적화로 생산성 향상",
      icon: Icons.dashboard,
      color: Color(0xFF388E3C),
    ),
    OnboardingData(
      title: "AI 챗봇 '소담이'",
      subtitle: "24시간 상시 상담 파트너",
      description: "🤖 궁금증을 해결해주는 챗봇\n\n농가의 다양한 질문에 정확하고 신속하게 답변하며, 질병 예측부터 사료 관리까지 전문적인 상담을 제공합니다.\n\n\"최근 체온 이상이 있는 소가 있니?\"와 같이 목장 상황에 맞춘 맞춤형 답변도 받을 수 있습니다.",
      icon: Icons.smart_toy,
      color: Color(0xFF81C784),
    ),
    OnboardingData(
      title: "시작해보세요!",
      subtitle: "스마트한 젖소 관리의 시작",
      description: "소담소담과 함께 더 효율적이고 과학적인 젖소 관리를 경험해보세요.\n\n🚀 생산성 향상\n📊 과학적 관리\n💡 AI 기반 예측\n🔄 효율적 운영",
      icon: Icons.rocket_launch,
      color: Color(0xFF4CAF50),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 진행 표시줄과 건너뛰기 버튼
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 진행 표시줄
                  Row(
                    children: List.generate(
                      _totalPages,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentPage
                              ? _pages[_currentPage].color
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  // 건너뛰기 버튼
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _skipToEnd,
                      child: Text(
                        '건너뛰기',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 메인 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 화면 높이에 따라 아이콘 크기와 여백 조정
                        final double iconSize = constraints.maxHeight > 600 ? 120 : 100;
                        final double spacing = constraints.maxHeight > 600 ? 32 : 24;
                        final double smallSpacing = constraints.maxHeight > 600 ? 24 : 16;
                        
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 아이콘
                                Container(
                                  width: iconSize,
                                  height: iconSize,
                                  decoration: BoxDecoration(
                                    color: page.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(iconSize / 2),
                                  ),
                                  child: page.image ??
                                    Icon(
                                      page.icon,
                                      size: iconSize * 0.5,
                                      color: page.color,
                                    ),
                                ),
                                SizedBox(height: spacing),
                                
                                // 제목
                                Text(
                                  page.title,
                                  style: TextStyle(
                                    fontSize: constraints.maxHeight > 600 ? 28 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                
                                // 부제목
                                Text(
                                  page.subtitle,
                                  style: TextStyle(
                                    fontSize: constraints.maxHeight > 600 ? 18 : 16,
                                    color: page.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: smallSpacing),
                                
                                // 설명
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    page.description,
                                    style: TextStyle(
                                      fontSize: constraints.maxHeight > 600 ? 16 : 14,
                                      color: Colors.grey,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이전 버튼
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '이전',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // 다음/시작하기 버튼
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _totalPages - 1 ? '시작하기' : '다음',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_currentPage < _totalPages - 1) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData? icon;
  final Color color;
  final Image? image;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon,
    required this.color,
    this.image,
  });
} 