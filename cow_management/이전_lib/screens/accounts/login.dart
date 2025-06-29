import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'dart:math';
import 'find_user_id_page.dart';
import 'find_password_page.dart';
import '../../services/auth/google_auth_service.dart';
import '../../services/auth/token_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController(); // 아이디 컨트롤러로 변경
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late String baseUrl;
  final _logger = Logger('LoginPage');
  
  // 깜찍한 로딩 메시지들
  final List<String> _loadingMessages = [
    '로그인 중이에요! 🐄',
    '젖소들이 기다리고 있어요! 🥛',
    '농장으로 가는 중... 🚜',
    '소담소담 준비 중! ✨',
    '목장 문을 여는 중... 🚪',
    '우유 짜러 가볼까요? 🐮',
    '농장 친구들이 반겨요! 🌾',
  ];
  
  String get _randomLoadingMessage {
    final random = Random();
    return _loadingMessages[random.nextInt(_loadingMessages.length)];
  }

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
  }



  // 개발자 문의 다이얼로그 표시
  void _showDeveloperContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('서버 연결 오류'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '서버에 이상이 생긴 것 같습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '다음과 같은 문제일 수 있습니다:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• 서버가 일시적으로 중단됨'),
              Text('• 네트워크 연결 문제'),
              Text('• 서버 점검 중'),
              SizedBox(height: 16),
              Text(
                '문제가 지속되면 개발자에게 문의해주세요.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    '개발자 문의: team@blackcowsdairy.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _copyEmailToClipboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('이메일 복사'),
            ),
          ],
        );
      },
    );
  }

  // 이메일 주소 클립보드 복사
  Future<void> _copyEmailToClipboard() async {
    try {
      await Clipboard.setData(const ClipboardData(text: 'team@blackcowsdairy.com'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개발자 이메일 주소가 클립보드에 복사되었습니다.\n이메일 앱에서 붙여넣기 하세요.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.warning('클립보드 복사 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복사에 실패했습니다. 수동으로 입력해주세요: team@blackcowsdairy.com'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 모두 입력해주세요!')),
      );
      return;
    }

    if (userId.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 최소 3글자 이상이어야 합니다!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.loginWithResult(userId, password, '$baseUrl/auth/login');

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        // 로그인 성공 시 CowProvider 데이터 초기화 및 새로 불러오기
        final cowProvider = Provider.of<CowProvider>(context, listen: false);
        cowProvider.clearAll();
        if (userProvider.accessToken != null) {
          await cowProvider.fetchCowsFromBackend(userProvider.accessToken!);
        }
        // 로그인 성공 시 즉시 화면 전환
        Navigator.pushReplacementNamed(context, '/main');
      } else if (mounted) {
        // 로그인 실패 시 비밀번호 필드 초기화
        _passwordController.clear();
        
        // 에러 타입에 따른 처리
        if (result.errorType == LoginErrorType.serverError || 
            result.errorType == LoginErrorType.timeout ||
            result.errorType == LoginErrorType.unknown) {
          // 서버 문제 시 개발자 문의 다이얼로그 표시
          _showDeveloperContactDialog();
        } else {
          // 일반적인 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        _passwordController.clear();
        _logger.severe('로그인 예외 발생: $e');
        
        // 예외 발생 시에도 개발자 문의 다이얼로그 표시
        _showDeveloperContactDialog();
      }
    }
  }

  // 구글 로그인 처리
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await GoogleAuthService.signInWithGoogle();

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        // 구글 로그인 성공 시 토큰 저장
        if (result.accessToken != null && result.refreshToken != null) {
          await TokenManager.saveTokens(
            accessToken: result.accessToken!,
            refreshToken: result.refreshToken!,
          );
        }

        // CowProvider 데이터 초기화 및 새로 불러오기
        final cowProvider = Provider.of<CowProvider>(context, listen: false);
        cowProvider.clearAll();
        
        if (result.accessToken != null) {
          await cowProvider.fetchCowsFromBackend(result.accessToken!);
        }
        
        Navigator.pushReplacementNamed(context, '/main');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        _logger.severe('구글 로그인 예외 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구글 로그인 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 메인 로그인 폼
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Text(
                '소담소담 로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              
              // 아이디 입력 필드 (username → user_id로 변경)
              TextField(
                controller: _userIdController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9_]'), // 영문, 숫자, 언더스코어만 허용
                  ),
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                  hintText: 'farmer123',
                ),
              ),
              const SizedBox(height: 16),
              
              // 비밀번호 입력 필드
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : _login(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  helperText: '영어, 숫자, 허용된 특수문자만 사용 가능',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _randomLoadingMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 아이디/비밀번호 찾기 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FindUserIdPage()),
                      );
                    },
                    child: const Text("아이디 찾기"),
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.grey,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FindPasswordPage()),
                      );
                    },
                    child: const Text("비밀번호 찾기"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 구글 로그인 구분선
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는 구글로 로그인하세요',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 24),
              
              // 구글 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.login,
                        color: Color(0xFF4285F4),
                        size: 24,
                      );
                    },
                  ),
                  label: const Text(
                    '구글로 로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 회원가입 버튼
              TextButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/signup');
                  if (result == true) {
                    // 회원가입 성공 시 텍스트 필드 초기화
                    _userIdController.clear();
                    _passwordController.clear();
                  }
                },
                child: const Text("아직 회원이 아니신가요? 회원가입"),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}