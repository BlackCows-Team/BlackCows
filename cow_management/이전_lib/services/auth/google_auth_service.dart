import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/dio_client.dart';

class GoogleAuthService {
  static final _logger = Logger('GoogleAuthService');
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 구글 로그인 실행
  static Future<GoogleSignInResult> signInWithGoogle() async {
    // 웹에서는 구글 로그인 비활성화
    if (kIsWeb) {
      return GoogleSignInResult(
        success: false,
        message: '웹에서는 구글 로그인을 지원하지 않습니다.',
      );
    }
    
    try {
      _logger.info('구글 로그인 시작');

      // Google Sign-In 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.warning('구글 로그인 취소됨');
        return GoogleSignInResult(
          success: false,
          message: '로그인이 취소되었습니다.',
        );
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase 인증 크리덴셜 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _logger.info('구글 로그인 성공: ${user.email}');
        
        // BlackCows 서버에 사용자 정보 전송 및 JWT 토큰 받기
        final blackCowsResult = await _registerOrLoginWithBlackCows(user);
        
        if (blackCowsResult.success) {
          return GoogleSignInResult(
            success: true,
            message: '구글 로그인 성공',
            user: user,
            accessToken: blackCowsResult.accessToken,
            refreshToken: blackCowsResult.refreshToken,
          );
        } else {
          return GoogleSignInResult(
            success: false,
            message: blackCowsResult.message,
          );
        }
      } else {
        return GoogleSignInResult(
          success: false,
          message: '인증에 실패했습니다.',
        );
      }
    } catch (e) {
      _logger.severe('구글 로그인 오류: $e');
      return GoogleSignInResult(
        success: false,
        message: '로그인 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// BlackCows 서버에 구글 사용자 정보 전송
  static Future<BlackCowsAuthResult> _registerOrLoginWithBlackCows(User user) async {
    try {
      final dioClient = DioClient();
      
      // ID 토큰 가져오기
      final idToken = await user.getIdToken();
      
      // BlackCows 서버로 로그인 요청 (백엔드 스펙에 맞춤)
      final response = await dioClient.dio.post(
        '/sns/google/login',
        data: {
          'id_token': idToken,
          'farm_nickname': '${user.displayName ?? "사용자"}님의 목장',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return BlackCowsAuthResult(
          success: true,
          message: '서버 인증 성공',
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
      } else {
        return BlackCowsAuthResult(
          success: false,
          message: '서버 인증에 실패했습니다.',
        );
      }
    } catch (e) {
      _logger.severe('BlackCows 서버 인증 오류: $e');
      return BlackCowsAuthResult(
        success: false,
        message: '서버 연결에 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    if (kIsWeb) return;
    
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.info('구글 로그아웃 완료');
    } catch (e) {
      _logger.warning('구글 로그아웃 오류: $e');
    }
  }

  /// 현재 로그인된 사용자 정보 가져오기
  static User? getCurrentUser() {
    if (kIsWeb) return null;
    return _auth.currentUser;
  }

  /// 로그인 상태 확인
  static bool isSignedIn() {
    if (kIsWeb) return false;
    return _auth.currentUser != null;
  }
}

/// 구글 로그인 결과 클래스
class GoogleSignInResult {
  final bool success;
  final String message;
  final User? user;
  final String? accessToken;
  final String? refreshToken;

  GoogleSignInResult({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });
}

/// BlackCows 서버 인증 결과 클래스
class BlackCowsAuthResult {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;

  BlackCowsAuthResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
  });
} 