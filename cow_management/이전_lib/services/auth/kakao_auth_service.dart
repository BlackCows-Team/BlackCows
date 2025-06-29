import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'blackcows_auth_service.dart';

class KakaoAuthService {
  static Future<Map<String, dynamic>?> signInWithKakao() async {
    try {
      OAuthToken token;
      
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      
      // 사용자 정보 조회
      User user = await UserApi.instance.me();
      String nickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
      
      // BlackCows 서버로 로그인 요청
      return await BlackCowsAuthService.loginToServer(
        endpoint: '/sns/kakao/login',
        body: {
          'access_token': token.accessToken,
          'farm_nickname': '${nickname}님의 목장',
        },
      );
    } catch (error) {
      print('Kakao 로그인 실패: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      print('Kakao 로그아웃 실패: $error');
    }
  }
} 