import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // 앱 로고 및 제목
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xFFC8E6C9), // 연한 초록
                  borderRadius: BorderRadius.circular(75),
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                '소담소담',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                '소와 나누는 이야기',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'AI 기반 낙농 젖소 전문 관리 솔루션',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    '로그인하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '회원가입하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 이용약관 및 개인정보처리방침
              Wrap(
                children: [
                  const Text(
                    '계속 진행하시면 ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 이용약관 보기
                      _showTermsDialog(context);
                    },
                    child: const Text(
                      '이용약관',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF388E3C),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    ' 및 ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 개인정보처리방침 보기
                      _showPrivacyDialog(context);
                    },
                    child: const Text(
                      '개인정보처리방침',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF388E3C),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    '에 동의하는 것으로 간주됩니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이용약관'),
          content: const SingleChildScrollView(
            child: Text(
              '''소담소담 서비스 이용약관

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

본 약관은 2025년 6월 29일부터 시행됩니다.''',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('자세히 보기'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('개인정보처리방침'),
          content: const SingleChildScrollView(
            child: Text(
              '''소담소담 개인정보처리방침

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

본 방침은 2025년 6월 29일부터 적용됩니다.''',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 웹사이트 링크 열기
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('자세히 보기'),
            ),
          ],
        );
      },
    );
  }
} 