import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class FindUserIdPage extends StatefulWidget {
  const FindUserIdPage({super.key});

  @override
  State<FindUserIdPage> createState() => _FindUserIdPageState();
}

class _FindUserIdPageState extends State<FindUserIdPage> {
  final TextEditingController _usernameController = TextEditingController(); // 사용자 이름/실명
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _showResult = false;
  String? _foundUserId;
  String? _foundFarmNickname;
  
  late String baseUrl;
  final _logger = Logger('FindUserIdPage');

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
  }

  Future<void> _findUserId() async {
    final username = _usernameController.text.trim(); // 사용자 이름/실명
    final email = _emailController.text.trim();

    // 입력 검증
    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 이메일을 모두 입력해주세요.')),
      );
      return;
    }

    // 이름 유효성 검사 (한글, 영문만 허용)
    if (!RegExp(r'^[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 한글, 영문만 입력 가능합니다.')),
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

    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      final url = Uri.parse('$baseUrl/auth/find-user-id');
      _logger.info('아이디 찾기 요청 URL: $url');
      _logger.info('요청 데이터: username=$username, email=$email');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,  // 사용자 이름/실명
          'email': email,        // 이메일
        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');
      
      // UTF-8로 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        
        setState(() {
          _foundUserId = responseData['user_id'];
          _foundFarmNickname = responseData['farm_nickname'] ?? '';
          _showResult = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('아이디를 찾았습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('입력하신 이름과 이메일에 일치하는 계정을 찾을 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _logger.severe('아이디 찾기 실패: ${response.statusCode} - $responseBody');
        
        String errorMessage = _getErrorMessage(response.statusCode, responseBody);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _logger.severe('아이디 찾기 실패: $e');
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

  String _getErrorMessage(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return '입력한 정보를 다시 확인해주세요.';
      case 404:
        return '입력하신 이름과 이메일에 일치하는 계정을 찾을 수 없습니다.';
      case 500:
        return '서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '아이디 찾기 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  void _resetForm() {
    setState(() {
      _showResult = false;
      _foundUserId = null;
      _foundFarmNickname = null;
    });
    _usernameController.clear();
    _emailController.clear();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디 찾기'),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_showResult) ...[
              // 아이디 찾기 폼
              const Icon(
                Icons.search,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 24),
              const Text(
                '가입 시 입력한 이름과 이메일을\n입력해주세요.',
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
              
              // 찾기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _findUserId,
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
                          '아이디 찾기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // 결과 표시
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 24),
              const Text(
                '아이디를 찾았습니다!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 32),
              
              // 찾은 아이디 정보 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '찾은 아이디 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          '이름: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _usernameController.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          '아이디: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFC8E6C9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _foundUserId ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_foundFarmNickname != null && _foundFarmNickname!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            '목장: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _foundFarmNickname!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 액션 버튼들
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 로그인 페이지로 돌아가기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '로그인하러 가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      child: const Text(
                        '다시 찾기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}