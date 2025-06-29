import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/main.dart';
import 'package:cow_management/screens/accounts/login.dart';
import 'package:logging/logging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      _logger.info('스플래시 화면 시작 - 첫 설치 여부 및 자동 로그인 확인');
      
      // 최소 1초는 스플래시 화면을 보여줌
      final delayFuture = Future.delayed(const Duration(seconds: 1));
      
      // SharedPreferences에서 온보딩 완료 여부 확인
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      
      await delayFuture;
      
      if (!mounted) return;
      
      // 온보딩을 완료하지 않은 첫 설치 사용자인 경우
      if (!onboardingCompleted) {
        _logger.info('첫 설치 사용자 - 온보딩 화면으로 이동');
        Navigator.pushReplacementNamed(context, '/onboarding');
        return;
      }
      
      // 온보딩을 완료한 기존 사용자인 경우 - 자동 로그인 확인
      _logger.info('기존 사용자 - 자동 로그인 확인');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      
      final isLoggedIn = await userProvider.checkAutoLogin();

      if (!mounted) return;

      if (isLoggedIn) {
        _logger.info('자동 로그인 성공 - 사용자 데이터 로딩');
        
        // 자동 로그인 성공 시 소 목록도 함께 로드
        if (userProvider.accessToken != null) {
          try {
            // CowProvider 초기화 및 데이터 로드
            cowProvider.clearAll();
            await cowProvider.fetchCowsFromBackend(userProvider.accessToken!, forceRefresh: true, userProvider: userProvider);
            _logger.info('소 목록 데이터 로딩 완료');
          } catch (e) {
            _logger.warning('소 목록 로딩 실패 (자동 로그인 시): $e');
            // 소 목록 로딩 실패해도 메인 화면으로 이동 (홈 화면에서 재시도 가능)
          }
        }
        
        // 메인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _logger.info('자동 로그인 실패 - 회원가입/로그인 선택 화면으로 이동');
        // 자동 로그인 실패 시 회원가입/로그인 선택 화면으로
        Navigator.pushReplacementNamed(context, '/auth_selection');
      }
    } catch (e) {
      _logger.severe('스플래시 화면 에러: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth_selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 또는 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 앱 이름
            const Text(
              '소담소담',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // 부제목
            const Text(
              '스마트 젖소 관리 시스템',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            
            // 로딩 인디케이터
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '로딩 중...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 