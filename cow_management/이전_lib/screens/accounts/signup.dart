import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController(); // 사용자 이름/실명
  final TextEditingController _userIdController = TextEditingController();   // 로그인용 아이디
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _farmNicknameController = TextEditingController(); // 목장 별명
  
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _agreeToTerms = false; // 서비스 이용약관 동의
  bool _agreeToPrivacy = false; // 개인정보 수집·이용 동의
  
  late String baseUrl;
  final _logger = Logger('SignupPage');

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      _logger.warning('경고: API_BASE_URL이 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
  }

  Future<void> _signup() async {
    final username = _usernameController.text.trim();    // 사용자 이름/실명
    final userId = _userIdController.text.trim();        // 로그인용 아이디
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final farmNickname = _farmNicknameController.text.trim();

    if (!_validateInputs()) {
      return;
    }
    
    // 필수 약관 동의 검증
    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('필수 약관에 동의해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isDialogOpen = true;
    
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // 뒤로가기 버튼 비활성화
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('회원가입 시도 중...'),
                const SizedBox(height: 8),
                Text(
                  '계정을 생성하고 있습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final url = Uri.parse('$baseUrl/auth/register');
      _logger.info('회원가입 요청 URL: $url');
      _logger.info('요청 데이터: username=$username, user_id=$userId, email=$email, farm_nickname=$farmNickname');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          'username': username,           // 사용자 이름/실명
          'user_id': userId,              // 로그인용 아이디
          'email': email,                 // 이메일
          'password': password,           // 비밀번호
          'password_confirm': passwordConfirm, // 비밀번호 확인
          'farm_nickname': farmNickname.isNotEmpty ? farmNickname : null, // 목장 별명 (선택사항)

        }),
      );

      _logger.info('응답 상태코드: ${response.statusCode}');
      
      // UTF-8로 디코딩
      final responseBody = utf8.decode(response.bodyBytes);
      _logger.info('응답 본문: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        _logger.info('회원가입 성공! 자동 로그인을 시도합니다.');
        
        // 로딩 메시지 업데이트 - 자동 로그인 단계
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop(); // 기존 다이얼로그 닫기
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('자동 로그인 중...'),
                      const SizedBox(height: 8),
                      Text(
                        '홈 화면으로 이동하고 있습니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        
        // 회원가입 성공 후 자동 로그인 시도
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final loginSuccess = await userProvider.login(userId, password, '$baseUrl/auth/login');
        
        // 로딩 다이얼로그 닫기
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
        
        if (loginSuccess && mounted) {
          _logger.info('자동 로그인 성공! 홈 화면으로 이동합니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입 완료! 자동 로그인되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 잠시 대기 후 홈 화면으로 이동
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false, // 모든 이전 화면 제거
            );
          }
        } else {
          _logger.warning('자동 로그인 실패. 로그인 페이지로 이동합니다.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? '회원가입 성공! 로그인해주세요.')),
            );
            Navigator.pop(context, true); // 성공 시 true 반환
          }
        }
      } else {
        _logger.severe('회원가입 실패: ${response.statusCode} - $responseBody');
        
        // 로딩 다이얼로그가 열려있으면 닫기
        if (isDialogOpen && mounted) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
        
        // 회원가입 실패 시 비밀번호 필드들 초기화
        _passwordController.clear();
        _passwordConfirmController.clear();
        
        if (mounted) {
          // 서버 오류 시 개발자 문의 다이얼로그 표시
          if (response.statusCode >= 500) {
            _showDeveloperContactDialog();
          } else {
            String errorMessage = _getErrorMessage(response.statusCode, responseBody);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      }
    } catch (e) {
      _logger.severe('회원가입 실패: $e');
      
      // 로딩 다이얼로그가 열려있으면 닫기
      if (isDialogOpen && mounted) {
        Navigator.of(context).pop();
        isDialogOpen = false;
      }
      
      // 네트워크 오류 시에도 비밀번호 필드들 초기화
      _passwordController.clear();
      _passwordConfirmController.clear();
      
      if (mounted) {
        // 네트워크 연결 문제인지 확인하고 개발자 문의 다이얼로그 표시
        if (e.toString().contains('SocketException') || 
            e.toString().contains('TimeoutException') ||
            e.toString().contains('Connection refused') ||
            baseUrl.isEmpty) {
          _showDeveloperContactDialog();
        } else {
          // 일반적인 네트워크 오류
          String errorMessage = '네트워크 오류가 발생했습니다: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  // 약관 보기 바텀시트
  void _showTermsDialog(BuildContext context, String title) {
    String content = '';
    IconData icon = Icons.description;
    Color iconColor = Colors.blue;
    
    switch (title) {
      case '서비스 이용약관':
        icon = Icons.gavel;
        iconColor = Colors.blue;
        content = '''소담소담 서비스 이용약관

제1조 (목적)
이 약관은 blackcowsdairy(이하 "회사")가 제공하는 낙농 관리 어플리케이션 '소담소담'(이하 "서비스")의 이용과 관련하여 회사와 이용자간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (용어의 정의)
1. "서비스"란 회사가 제공하는 낙농 관리 어플리케이션 '소담소담' 및 관련 제반 서비스를 의미합니다.
2. "이용자" 또는 "회원"이란 이 약관에 따라 서비스를 이용하는 자를 의미합니다.
3. "계정"이란 서비스 이용을 위해 회원이 설정한 로그인 아이디와 비밀번호의 조합을 의미합니다.
4. "콘텐츠"란 서비스 내에서 이용자가 생성, 등록, 수정하는 젖소 정보, 관리 기록, 목장 정보 등을 의미합니다.
5. "축산물 이력제 연동 서비스"란 이표번호를 통해 축산물품질평가원의 정보를 조회하는 서비스를 의미합니다.

제3조 (서비스의 제공)
회사가 제공하는 서비스의 내용은 다음과 같습니다:
1. 회원 관리 서비스: 회원가입, 로그인, 계정 관리
2. 농장 관리 서비스: 목장 정보 설정 및 관리
3. 젖소 관리 서비스: 젖소 정보 등록, 관리 기록 작성 및 조회
4. 축산물 이력제 연동 서비스: 이표번호를 통한 정부 데이터베이스 연동
5. AI 분석 서비스: 젖소 건강상태 및 생산성 예측 분석
6. AI 챗봇 서비스: 낙농 관련 상담 및 정보 제공
7. 기타 회사가 추가로 개발하거나 제공하는 일체의 서비스

제4조 (서비스 이용 대상)
본 서비스는 주로 낙농업 종사자를 대상으로 개발되었습니다. 낙농업에 대한 기본 지식이 있는 사용자의 이용을 전제로 하며, 다른 목적의 이용으로 인한 문제는 책임지지 않습니다.

제5조 (회원가입)
1. 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관과 개인정보처리방침에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.
2. 만 14세 미만은 회원가입이 불가능합니다.
3. 허위의 정보를 기재하거나 타인의 명의를 이용한 경우 회원등록이 거부될 수 있습니다.

제6조 (이용자의 의무)
이용자는 다음 행위를 하여서는 안됩니다:
1. 신청 또는 변경 시 허위 내용의 등록
2. 타인의 정보 도용
3. 회사 기타 제3자의 저작권 등 지적재산권에 대한 침해
4. 회사 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위
5. 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시하는 행위
6. 회사의 동의 없이 영리목적으로 서비스를 사용하는 행위

제7조 (축산물 이력제 연동 서비스)
1. 회사는 축산물품질평가원의 축산물통합이력정보 API를 통해 이표번호 기반 정보 조회 서비스를 제공합니다.
2. 해당 서비스는 정부 API의 운영 상황에 따라 일시적으로 중단될 수 있으며, 이는 회사의 책임 범위에 해당하지 않습니다.
3. 조회된 축산물 이력 정보는 정부 공개 데이터를 기반으로 하며, 정보의 정확성에 대한 최종 책임은 해당 정부 기관에 있습니다.

제8조 (AI 서비스)
1. 회사는 AI 기술을 활용한 분석 서비스 및 챗봇 서비스를 제공합니다.
2. AI 서비스의 결과는 참고용 정보이며, 실제 농장 관리 결정은 회원의 판단과 책임 하에 이루어져야 합니다.
3. 회사는 AI 서비스 결과의 정확성을 보장하지 않으며, 해당 결과로 인한 손해에 대해 책임지지 않습니다.
4. 회원의 개인정보는 AI 학습에 사용되지 않으며, 대화 내용은 14일 후 자동으로 삭제됩니다.

제9조 (면책조항)
1. 회사는 무료로 제공되는 서비스와 관련하여 회원에게 어떠한 손해가 발생하더라도 동 손해가 회사의 고의 또는 중대한 과실에 의한 경우를 제외하고는 이에 대하여 책임을 부담하지 아니합니다.
2. 회사는 축산물 이력제 연동 서비스를 통해 제공되는 정부 데이터의 정확성에 대해 책임을 지지 않습니다.
3. 회사는 AI 서비스를 통해 제공되는 분석 결과나 조언의 정확성을 보장하지 않으며, 이로 인한 손해에 대해 책임을 지지 않습니다.
4. 본 서비스는 낙농업 종사자를 주요 대상으로 개발되었습니다. 낙농업 이외의 목적으로 서비스를 이용하거나, 낙농업에 대한 전문 지식이 없는 상태에서 발생하는 문제에 대해서는 책임을 지지 않습니다.
5. 상업적 또는 전문적 농장 운영에 전적으로 의존해서는 안되며, 중요한 결정은 반드시 해당 분야 전문가와 상의하시기 바랍니다.

제10조 (개인정보보호)
회사는 관련법령이 정하는 바에 따라 회원의 개인정보를 보호하기 위해 노력하며, 개인정보의 수집, 이용 및 보호에 관한 사항은 별도의 개인정보처리방침에서 정합니다.

제11조 (서비스 운영팀 정보)
- 팀명: blackcowsdairy
- 담당자: 강슬기
- 연락처: support@blackcowsdairy.com
- 개인정보 관련 문의: support@blackcowsdairy.com

이 약관에서 정하지 아니한 사항과 이 약관의 해석에 관하여는 관련 법령 또는 상관례에 따릅니다.

본 약관은 2025년 6월 29일부터 시행됩니다.''';
        break;
        
      case '개인정보 수집·이용':
        icon = Icons.security;
        iconColor = Colors.green;
        content = '''소담소담 개인정보 수집·이용 동의서

blackcowsdairy(이하 "회사")는 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고자 다음과 같은 처리방침을 두고 있습니다.

1. 개인정보의 처리목적
회사는 다음의 목적을 위하여 개인정보를 처리합니다:
- 서비스 제공 및 계약의 이행
- 회원 관리 및 본인 확인
- 서비스 개선 및 맞춤형 서비스 제공
- 고객상담 및 민원처리
- AI 챗봇 서비스 제공

2. 처리하는 개인정보의 항목
[필수항목] 이름, 로그인 아이디, 이메일, 비밀번호
[선택항목] 목장명, 연락처
[서비스 이용정보] 젖소 관리 데이터, 챗봇 대화 내용, 접속 로그

3. 개인정보의 처리 및 보유기간
- 회원정보: 회원 탈퇴 시까지
- 젖소 관리 데이터: 회원 탈퇴 후 1년 (복구 요청 대응)
- 챗봇 대화 기록: 30일 (서비스 개선 목적)
- 접속 로그: 3개월 (보안 및 서비스 안정성)

4. 개인정보의 제3자 제공
회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 단, 다음의 경우는 예외로 합니다:
- 축산물이력제 API (농림축산식품부): 이표번호 조회 및 축산물 이력 확인
- OpenAI: AI 챗봇 서비스 제공 (개인식별정보 제외)
- 이용자가 사전에 동의한 경우
- 법령의 규정에 의거하거나 수사기관의 요구가 있는 경우

5. 개인정보의 파기
회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.

6. 정보주체의 권리·의무 및 행사방법
이용자는 개인정보주체로서 다음과 같은 권리를 행사할 수 있습니다:
- 개인정보 처리정지 요구
- 개인정보 정정·삭제 요구
- 개인정보 처리현황 통지 요구

개인정보 관련 문의: support@blackcowsdairy.com
본 방침은 2025년 6월 29일부터 적용됩니다.''';
        break;
        

    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 핸들바
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // 헤더
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  
                  // 구분선
                  Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  
                  // 내용
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // 하단 안내
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: iconColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: iconColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    '내용을 충분히 읽어보신 후 동의 여부를 결정해주세요.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 하단 버튼
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                                        child: Column(
                      children: [
                        // 개인정보 수집·이용인 경우 자세히 보기 버튼 추가
                        if (title == '개인정보 수집·이용') ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                const url = 'https://blackcows-team.github.io/blackcows-privacy/privacy-policy.html';
                                try {
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                  } else {
                                    throw '링크를 열 수 없습니다';
                                  }
                                } catch (e) {
                                  // URL을 열 수 없는 경우 클립보드에 복사
                                  await Clipboard.setData(const ClipboardData(text: url));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('링크가 클립보드에 복사되었습니다. 브라우저에서 붙여넣기 하세요.'),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text('완전한 개인정보처리방침 보기'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // 하단 버튼들
                        Column(
                          children: [
                            // 서비스 이용약관인 경우 자세히 보기 버튼 추가
                            if (title == '서비스 이용약관') ...[
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    // 웹사이트 링크 열기
                                    const url = 'https://blackcows-team.github.io/blackcows-privacy/terms-of-service.html';
                                    try {
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                      } else {
                                        throw '링크를 열 수 없습니다';
                                      }
                                    } catch (e) {
                                      // URL을 열 수 없는 경우 클립보드에 복사
                                      await Clipboard.setData(const ClipboardData(text: url));
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('링크가 클립보드에 복사되었습니다. 브라우저에서 붙여넣기 하세요.'),
                                            backgroundColor: Colors.blue,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text(
                                    '상세 약관 확인하기',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            Row(
                              children: [
                                // 닫기 버튼
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade600,
                                      side: BorderSide(color: Colors.grey.shade400),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '닫기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // 동의 버튼
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                       // 해당 약관에 동의 처리
                                       setState(() {
                                         if (title == '서비스 이용약관') {
                                           _agreeToTerms = true;
                                         } else if (title == '개인정보 수집·이용') {
                                           _agreeToPrivacy = true;
                                         }
                                       });
                                       Navigator.of(context).pop();
                                       
                                       // 동의 완료 스낵바 표시
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(
                                           content: Row(
                                             children: [
                                               Icon(Icons.check_circle, color: Colors.white, size: 20),
                                               const SizedBox(width: 8),
                                               Text('$title에 동의하셨습니다.'),
                                             ],
                                           ),
                                           backgroundColor: iconColor,
                                           duration: const Duration(seconds: 2),
                                         ),
                                       );
                                     },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '동의',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                backgroundColor: Color(0xFF4CAF50),
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

  bool _validateInputs() {
    final username = _usernameController.text.trim();    // 사용자 이름/실명
    final userId = _userIdController.text.trim();        // 로그인용 아이디
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();
    final farmNickname = _farmNicknameController.text.trim(); // 목장 별명

    // 필수 필드 검증
    if (username.isEmpty || userId.isEmpty || email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 필드를 모두 입력해주세요.')),
      );
      return false;
    }

    // 사용자 이름 유효성 검사 (한글, 영문만 허용)
    if (!RegExp(r'^[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 한글, 영문만 입력 가능합니다.')),
      );
      return false;
    }

    if (username.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 최소 2글자 이상이어야 합니다!')),
      );
      return false;
    }

    // 아이디 유효성 검사 (영문으로 시작, 영문+숫자+언더스코어)
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 영문으로 시작하고 영문, 숫자, 언더스코어(_)만 사용 가능합니다.')),
      );
      return false;
    }

    if (userId.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디는 최소 3글자 이상이어야 합니다!')),
      );
      return false;
    }

    if (password != passwordConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return false;
    }

    return true;
  }

     String _getErrorMessage(int statusCode, String responseBody) {
     switch (statusCode) {
       case 400:
         if (responseBody.contains('email')) {
           return '올바른 이메일 형식을 입력해주세요.';
         } else if (responseBody.contains('user_id') || responseBody.contains('아이디')) {
           return '이미 사용 중인 아이디입니다. 다른 아이디를 입력해주세요.';
         } else if (responseBody.contains('username') || responseBody.contains('이름')) {
           return '이름 형식이 올바르지 않습니다. 한글, 영문만 입력해주세요.';
         } else if (responseBody.contains('password')) {
           return '비밀번호가 조건에 맞지 않습니다. 다시 확인해주세요.';
         } else {
           return '입력한 정보를 다시 확인해주세요.';
         }
       case 404:
         return '서비스에 일시적인 문제가 있습니다. 잠시 후 다시 시도해주세요.';
       case 409:
         return '이미 등록된 정보입니다. 아이디나 이메일을 확인해주세요.';
       case 422:
         return '입력한 정보가 올바르지 않습니다. 다시 확인해주세요.';
       case 500:
         return '서버에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
       default:
         return '회원가입 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
     }
   }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _farmNicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 사용자 이름/실명 입력
            TextField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z\s]'), // 한글 전체 범위, 영문, 공백 허용
                ),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: '이름 *',
                helperText: '한글, 영문만 입력 가능 (2-20자)',
                hintText: '홍길동',
              ),
            ),
            const SizedBox(height: 16),
            
            // 로그인용 아이디 입력
            TextField(
              controller: _userIdController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9_]'), // 영문, 숫자, 언더스코어만 허용
                ),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: const InputDecoration(
                labelText: '아이디 *',
                helperText: '영문으로 시작, 영문+숫자+언더스코어(_) 가능 (3-20자)',
                hintText: 'farmer123',
              ),
            ),
            const SizedBox(height: 16),
            
            // 이메일 입력
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일 *',
                hintText: 'example@farm.com',
              ),
            ),
            const SizedBox(height: 16),
            
            // 비밀번호 입력
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              onTap: () {
                _passwordController.clear();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                ),
              ],
              decoration: InputDecoration(
                labelText: '비밀번호 *',
                helperText: '영어, 숫자, 허용된 특수문자만 사용 가능 (6-20자)',
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
            const SizedBox(height: 16),
            
            // 비밀번호 확인
            TextField(
              controller: _passwordConfirmController,
              obscureText: !_isPasswordConfirmVisible,
              onTap: () {
                _passwordConfirmController.clear();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9!"#$%&()*+,./:;<=>?@^_`{|}~\-\[\]\\]'),
                ),
              ],
              decoration: InputDecoration(
                labelText: '비밀번호 확인 *',
                helperText: '위에서 입력한 비밀번호를 다시 입력해주세요',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordConfirmVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 목장 별명 입력 (선택사항)
            TextField(
              controller: _farmNicknameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AFa-zA-Z0-9\s\-_()]'), // 한글 전체 범위, 영문, 숫자, 기본 특수문자
                ),
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(
                labelText: '목장 별명 (선택사항)',
                helperText: '입력하지 않으면 "이름님의 목장"으로 자동 설정됩니다',
                hintText: '행복한 목장',
              ),
            ),
            const SizedBox(height: 24),
            
            // 약관 동의 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '약관 동의',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 서비스 이용약관 동의 (필수)
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('서비스 이용약관 동의 (필수)'),
                      ),
                      TextButton(
                        onPressed: () => _showTermsDialog(context, '서비스 이용약관'),
                        child: const Text('보기'),
                      ),
                    ],
                  ),
                  
                  // 개인정보 수집·이용 동의 (필수)
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToPrivacy,
                        onChanged: (value) {
                          setState(() {
                            _agreeToPrivacy = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text('개인정보 수집·이용 동의 (필수)'),
                      ),
                      TextButton(
                        onPressed: () => _showTermsDialog(context, '개인정보 수집·이용'),
                        child: const Text('보기'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 전체 동의 버튼
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms && _agreeToPrivacy,
                        tristate: true,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                            _agreeToPrivacy = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        '전체 동의',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 안내 문구
            const Text(
              '* 표시된 항목은 필수 입력 항목입니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}