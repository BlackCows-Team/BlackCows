import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class FindPasswordPage extends StatefulWidget {
  const FindPasswordPage({super.key});

  @override
  State<FindPasswordPage> createState() => _FindPasswordPageState();
}

class _FindPasswordPageState extends State<FindPasswordPage> {
  final PageController _pageController = PageController();

  // 1단계: 사용자 정보 확인 폼
  final TextEditingController _usernameController =
      TextEditingController(); // 사용자 이름/실명
  final TextEditingController _userIdController =
      TextEditingController(); // 로그인용 아이디
  final TextEditingController _emailController = TextEditingController(); // 이메일

  // 2단계: 토큰 입력 폼
  final TextEditingController _tokenController = TextEditingController();

  // 3단계: 새 비밀번호 설정 폼
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _resetToken;
  String? _verifiedUsername;
  String? _verifiedUserId;

  late String baseUrl;
  final _logger = Logger('FindPasswordPage');

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
  }

  // 1단계: 사용자 정보 확인 및 재설정 토큰 요청
  Future<void> _requestPasswordReset() async {
    final username = _usernameController.text.trim(); // 사용자 이름/실명
    final userId = _userIdController.text.trim(); // 로그인용 아이디
    final email = _emailController.text.trim(); // 이메일

    // 입력 검증
    if (username.isEmpty || userId.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    // 이름 유효성 검사 (한글, 영문만 허용)
    if (!RegExp(r'^[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]+$')
        .hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 한글, 영문만 입력 가능합니다.')),
      );
      return;
    }

    // 아이디 유효성 검사
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 형식이 올바르지 않습니다.')),
      );
      return;
    }

    // 이메일 간단 유효성 검사
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 이메일 형식을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/request-password-reset');
      _logger.info('비밀번호 재설정 요청 URL: $url');
      _logger.info('요청 데이터: username=$username, user_id=$userId, email=$email');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username, // 사용자 이름/실명
          'user_id': userId, // 로그인용 아이디
          'email': email, // 이메일
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');

      // UTF-8로 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        setState(() {
          _resetToken = responseData['reset_token']; // 임시 토큰
          _verifiedUsername = responseData['username'];
          _verifiedUserId = responseData['user_id'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? '재설정 토큰이 발급되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 2단계로 이동 (토큰 입력)
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('입력하신 이름, 아이디, 이메일이 모두 일치하는 계정을 찾을 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger
            .severe('비밀번호 재설정 요청 실패: ${response.statusCode} - $responseBody');

        String errorMessage =
            _getErrorMessage(response.statusCode, responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _logger.severe('비밀번호 재설정 요청 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2단계: 토큰 확인
  Future<void> _verifyResetToken() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재설정 토큰을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/verify-reset-token');
      _logger.info('토큰 확인 요청 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');

      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? '토큰이 확인되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 3단계로 이동 (새 비밀번호 설정)
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유효하지 않은 재설정 토큰입니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _logger.severe('토큰 확인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3단계: 새 비밀번호 설정
  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final token = _tokenController.text.trim();

    // 입력 검증
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 최소 6글자 이상이어야 합니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/reset-password');
      _logger.info('비밀번호 재설정 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');

      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? '비밀번호가 성공적으로 변경되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 성공 다이얼로그 표시
        _showSuccessDialog();
      } else {
        _logger.severe('비밀번호 재설정 실패: ${response.statusCode} - $responseBody');

        String errorMessage =
            _getErrorMessage(response.statusCode, responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _logger.severe('비밀번호 재설정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네트워크 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('비밀번호 변경 완료'),
            ],
          ),
          content: Text(
            '$_verifiedUsername님의 비밀번호가 성공적으로 변경되었습니다.\n'
            '새로운 비밀번호로 로그인해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 비밀번호 찾기 페이지 닫기
              },
              child: const Text(
                '로그인하러 가기',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return '입력한 정보를 다시 확인해주세요.';
      case 404:
        return '입력하신 정보와 일치하는 계정을 찾을 수 없습니다.';
      case 500:
        return '서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '비밀번호 찾기 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
        children: [
          _buildStep1(), // 1단계: 사용자 정보 확인
          _buildStep2(), // 2단계: 토큰 입력
          _buildStep3(), // 3단계: 새 비밀번호 설정
        ],
      ),
    );
  }

  // 1단계: 사용자 정보 확인
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          const Text(
            '비밀번호 재설정을 위해\n계정 정보를 확인합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // 이름 입력 필드
          TextField(
            controller: _usernameController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[가-힣a-zA-Z\s]'), // 한글, 영문, 공백만 허용
              ),
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              helperText: '가입 시 입력한 이름을 정확히 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 아이디 입력 필드
          TextField(
            controller: _userIdController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9_]'), // 영문, 숫자, 언더스코어만 허용
              ),
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: const InputDecoration(
              labelText: '아이디',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle),
              helperText: '로그인에 사용하는 아이디를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 이메일 입력 필드
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              helperText: '가입 시 사용한 이메일 주소를 입력해주세요',
            ),
          ),
          const SizedBox(height: 32),

          // 다음 단계 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestPasswordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '계정 확인 및 토큰 발급',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 2단계: 토큰 입력
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.security,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          Text(
            '$_verifiedUsername님,\n발급된 재설정 토큰을 입력해주세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.info, color: Colors.blue, size: 24),
                const SizedBox(height: 8),
                const Text(
                  '개발 모드 안내',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '실제 환경에서는 이메일로 토큰이 발송됩니다.\n'
                  '현재는 개발 모드로 아래 토큰을 사용하세요:\n'
                  '${_resetToken ?? "토큰 로딩 중..."}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 토큰 입력 필드
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(
              labelText: '재설정 토큰',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key),
              helperText: '발급받은 토큰을 정확히 입력해주세요',
            ),
          ),
          const SizedBox(height: 32),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyResetToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '토큰 확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // 이전 단계 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text(
                '이전 단계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3단계: 새 비밀번호 설정
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 80,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          Text(
            '$_verifiedUsername님,\n새로운 비밀번호를 설정해주세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),

          // 새 비밀번호 입력 필드
          TextField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
              ),
            ],
            decoration: InputDecoration(
              labelText: '새 비밀번호',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              helperText: '영어, 숫자, 허용된 특수문자만 사용 가능 (6-20자)',
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 비밀번호 확인 입력 필드
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
              ),
            ],
            decoration: InputDecoration(
              labelText: '새 비밀번호 확인',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              helperText: '위에서 입력한 비밀번호를 다시 입력해주세요',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 비밀번호 변경 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '비밀번호 변경',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // 이전 단계 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text(
                '이전 단계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
