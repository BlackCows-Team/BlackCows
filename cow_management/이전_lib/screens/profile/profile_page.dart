import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/onboarding/auth_selection_page.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _deleteErrorMessage;
  bool _obscureDeletePassword = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 헤더
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? '알 수 없음',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '아이디: ${user?.userId ?? '알 수 없음'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          user?.email ?? '이메일 없음',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user?.farmNickname != null && user!.farmNickname!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🏡 ${user.farmNickname}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            // 계정 정보 섹션 (바로 표시)
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '계정 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildInfoRow('이름', user?.username ?? '정보 없음'),
                        _buildInfoRow('로그인 아이디', user?.userId ?? '정보 없음'),
                        _buildInfoRow('이메일', user?.email ?? '정보 없음'),
                        _buildInfoRow('목장', user?.farmNickname ?? '정보 없음'),
                        _buildInfoRow('가입일', user?.createdAt != null 
                          ? user!.createdAt!.split('T')[0] 
                          : '정보 없음'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 나의 활동 섹션
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '나의 활동',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildMenuTile(
                    icon: Icons.edit,
                    title: '목장 이름 수정',
                    onTap: () => _showEditFarmNameDialog(context, userProvider),
                    iconColor: Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 기타 섹션
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '기타',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildMenuTile(
                    icon: Icons.help_outline,
                    title: '개발자에게 문의하기',
                    onTap: () {
                      // 문의 기능 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('문의 기능 준비중입니다.')),
                      );
                    },
                    iconColor: Colors.orange,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuTile(
                    icon: Icons.description,
                    title: '앱 사용설명',
                    onTap: () {
                      // 사용설명 기능 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용설명 기능 준비중입니다.')),
                      );
                    },
                    iconColor: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 앱 정보 섹션
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '앱 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildMenuTile(
                    icon: Icons.description,
                    title: '서비스 이용약관',
                    onTap: () => _showTermsOfService(context),
                    iconColor: Colors.grey,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuTile(
                    icon: Icons.privacy_tip,
                    title: '개인정보처리방침',
                    onTap: () => _showPrivacyPolicy(context),
                    iconColor: Colors.grey,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.grey),
                    title: const Text('버전정보 1.0.0'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '최신버전',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 계정 관리 섹션
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.logout,
                    title: '로그아웃',
                    onTap: () => _showLogoutConfirmDialog(context, userProvider),
                    iconColor: Colors.orange,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuTile(
                    icon: Icons.delete_forever,
                    title: '회원 탈퇴',
                    onTap: () => _showDeleteAccountDialog(context, userProvider),
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('서비스 이용약관'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '제1조 (목적)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '이 약관은 blackcowsdairy(이하 "회사")가 제공하는 낙농 관리 어플리케이션 \'소담소담\'(이하 "서비스")의 이용과 관련하여 회사와 이용자간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '제2조 (용어의 정의)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '1. "서비스"란 회사가 제공하는 낙농 관리 어플리케이션 \'소담소담\' 및 관련 제반 서비스를 의미합니다.\n'
                    '2. "이용자" 또는 "회원"이란 이 약관에 따라 서비스를 이용하는 자를 의미합니다.\n'
                    '3. "계정"이란 서비스 이용을 위해 회원이 설정한 로그인 아이디와 비밀번호의 조합을 의미합니다.\n'
                    '4. "콘텐츠"란 서비스 내에서 이용자가 생성, 등록, 수정하는 젖소 정보, 관리 기록, 목장 정보 등을 의미합니다.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '제5조 (서비스의 내용 및 대상)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '회사가 제공하는 서비스의 내용은 다음과 같습니다:\n'
                    '1. 회원 관리 서비스: 회원가입, 로그인, 계정 관리\n'
                    '2. 농장 관리 서비스: 목장 정보 설정 및 관리\n'
                    '3. 젖소 관리 서비스: 젖소 정보 등록, 관리 기록 작성 및 조회\n'
                    '4. 축산물 이력제 연동 서비스: 이표번호를 통한 정부 데이터베이스 연동\n'
                    '5. AI 분석 서비스: 젖소 건강상태 및 생산성 예측 분석\n'
                    '6. AI 챗봇 서비스: 낙농 관련 상담 및 정보 제공',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📋 서비스 이용 대상',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                  ),
                  const Text(
                    '본 서비스는 주로 낙농업 종사자를 대상으로 개발된 대학생 팀 프로젝트입니다. 낙농업에 대한 기본 지식이 있는 사용자의 이용을 전제로 하며, 다른 목적의 이용으로 인한 문제는 책임지지 않습니다.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '⚠️ 중요한 면책사항',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                  const Text(
                    '• AI 분석 결과 및 축산물 이력제 정보는 참고용이며, 실제 농장 운영 결정은 반드시 전문가와 상의하거나 본인의 판단 하에 이루어져야 합니다.\n'
                    '• 본 서비스는 낙농업 종사자를 위한 창업경진대회 참여작으로 개발되었습니다.\n'
                    '• 상업적 농장 운영에 전적으로 의존하지 마시고, 중요한 결정은 해당 분야 전문가와 상의하시기 바랍니다.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '시행일: 2025년 6월 29일',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('개인정보 처리방침'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 개인정보 처리방침 개요',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                  ),
                  const Text(
                    'blackcowsdairy(이하 \'회사\')는 정보주체의 자유와 권리 보호를 위해 「개인정보 보호법」 및 관계 법령이 정한 바를 준수하여, 적법하게 개인정보를 처리하고 안전하게 관리하고 있습니다.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '1. 개인정보의 처리목적',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '회사는 낙농 관리 어플리케이션 \'소담소담\' 서비스 제공을 위해 다음의 목적으로 개인정보를 처리합니다:\n'
                    '• 회원 인증 및 사용자 식별\n'
                    '• 농장 관리 서비스 제공\n'
                    '• 서비스 운영 및 고지사항 전달\n'
                    '• 낙농 관리 서비스 제공\n'
                    '• AI 챗봇 서비스 제공\n'
                    '• AI 분석 서비스 제공\n'
                    '• 축산물 이력제 연동 서비스\n'
                    '• 위치 기반 서비스 제공',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. 처리하는 개인정보의 항목',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '필수 수집 정보:\n'
                    '• 사용자 이름(실명)\n'
                    '• 로그인 아이디\n'
                    '• 이메일 주소\n'
                    '• 비밀번호(암호화 저장)\n\n'
                    '선택 수집 정보:\n'
                    '• 목장 별명\n'
                    '• 젖소 관리 데이터\n'
                    '• AI 챗봇 이용 데이터',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. 개인정보의 처리 및 보유 기간',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text(
                    '• 회원 정보: 회원 탈퇴 시까지\n'
                    '• 젖소 관리 데이터: 회원 탈퇴 후 1년\n'
                    '• AI 챗봇 대화내용: 수집일로부터 14일\n'
                    '• 로그 기록: 수집일로부터 3개월',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📞 개인정보 보호책임자',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple),
                  ),
                  const Text(
                    '성명: 강슬기\n'
                    '연락처: support@blackcowsdairy.com',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '📋 본 개인정보 처리방침은 낙농업 종사자를 위한 창업경진대회 참여작으로 제작되었습니다.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const Text(
                    '제10회 농림축산식품 공공데이터 활용 창업경진대회에 참여하는 서비스이므로, 중요한 개인정보 관련 결정은 반드시 전문가와 상의하시기 바랍니다.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '시행일: 2025년 6월 29일',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        );
      },
    );
  }

  void _showEditFarmNameDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController controller = TextEditingController();
    final user = userProvider.currentUser;
    
    if (user?.farmNickname != null) {
      controller.text = user!.farmNickname!;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('목장 이름 수정'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '목장 이름을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                final newFarmName = controller.text.trim();
                if (newFarmName.isNotEmpty) {
                  try {
                    await userProvider.updateFarmName(newFarmName);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('목장 이름이 수정되었습니다.'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('목장 이름 수정에 실패했습니다: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('수정', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                userProvider.logout();
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil('/auth_selection', (route) => false);
              },
              child: const Text('로그아웃', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원 탈퇴', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ 회원 탈퇴 시 다음 정보가 즉시 완전 삭제됩니다:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 12),
              const Text(
                '• 사용자 개인정보 (이름, 이메일, 목장정보 등)\n'
                '• 등록된 젖소 목록 및 모든 젖소 정보\n'
                '• 건강검진, 치료, 백신접종 등 모든 기록\n'
                '• 사료급여, 착유, 번식 등 관리 기록\n'
                '• AI 챗봇 대화 내용 및 분석 결과\n'
                '• 예측 분석 데이터 및 리포트\n'
                '• 계정 설정 및 앱 사용 기록',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                '⚠️ 삭제된 정보는 복구가 불가능합니다.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscureDeletePassword,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호 확인',
                  hintText: '비밀번호를 입력하세요',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureDeletePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureDeletePassword = !_obscureDeletePassword;
                      });
                    },
                  ),
                  errorText: _deleteErrorMessage,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  setState(() {
                    _deleteErrorMessage = '비밀번호를 입력해주세요.';
                  });
                  return;
                }
                
                try {
                  final success = await userProvider.deleteAccount(password);
                  if (success) {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('회원 탈퇴가 완료되었습니다.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    setState(() {
                      _deleteErrorMessage = '비밀번호가 올바르지 않습니다.';
                    });
                  }
                } catch (e) {
                  setState(() {
                    _deleteErrorMessage = '탈퇴 처리 중 오류가 발생했습니다.';
                  });
                }
              },
              child: const Text('탈퇴하기', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}