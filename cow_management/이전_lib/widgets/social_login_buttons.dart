import 'package:flutter/material.dart';
import '../services/auth/kakao_auth_service.dart';

class SocialLoginButtons extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;

  const SocialLoginButtons({
    Key? key,
    this.onLoginSuccess,
    this.onLoginError,
  }) : super(key: key);

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isLoading = false;

  Future<void> _handleLogin(String provider, Future<Map<String, dynamic>?> Function() loginFunction) async {
    setState(() => _isLoading = true);

    try {
      final result = await loginFunction();
      
      if (result != null) {
        widget.onLoginSuccess?.call();
      } else {
        widget.onLoginError?.call('$provider 로그인에 실패했습니다');
      }
    } catch (error) {
      widget.onLoginError?.call('$provider 로그인 중 오류가 발생했습니다: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kakao 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _handleLogin(
              'Kakao',
              KakaoAuthService.signInWithKakao,
            ),
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Color(0xFFFFE812),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            label: const Text('카카오로 로그인'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE812),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
} 