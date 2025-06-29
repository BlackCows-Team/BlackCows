import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlackCowsAuthService {
  static String get baseUrl {
    // .env 파일에서 서버 URL을 가져오거나 기본값 사용
    return dotenv.env['BASE_URL'] ?? 'https://your-blackcows-server.com';
  }

  static Future<Map<String, dynamic>?> loginToServer({
    required String endpoint,
    required Map<String, String> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('BlackCows 로그인 응답 상태: ${response.statusCode}');
      print('BlackCows 로그인 응답: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // JWT 토큰 저장
        await TokenManager.saveTokens(
          accessToken: responseData['access_token'],
          refreshToken: responseData['refresh_token'],
        );
        
        // 사용자 정보 저장
        await TokenManager.saveUserInfo(responseData['user']);
        
        return responseData;
      } else {
        print('BlackCows 로그인 실패: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('BlackCows 서버 통신 실패: $error');
      return null;
    }
  }

  // 인증이 필요한 API 호출
  static Future<http.Response?> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await TokenManager.getAccessToken();
    if (token == null) return null;

    try {
      final request = http.Request(method, Uri.parse('$baseUrl$endpoint'));
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (error) {
      print('인증 API 요청 실패: $error');
      return null;
    }
  }
} 