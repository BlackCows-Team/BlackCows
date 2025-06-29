import 'package:flutter/material.dart';
import 'package:cow_management/models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// 로그인 에러 타입 정의
enum LoginErrorType {
  success,
  invalidCredentials,  // 아이디/비밀번호 오류
  serverError,         // 서버 오류
  networkError,        // 네트워크 연결 오류
  timeout,             // 타임아웃
  rateLimited,         // 요청 제한
  unknown              // 알 수 없는 오류
}

// 로그인 결과 클래스
class LoginResult {
  final bool success;
  final LoginErrorType errorType;
  final String message;

  LoginResult({
    required this.success,
    this.errorType = LoginErrorType.success,
    this.message = '',
  });
}

class UserProvider with ChangeNotifier {
  final _logger = Logger('UserProvider');
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _shouldShowWelcome = false;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  bool get shouldShowWelcome => _shouldShowWelcome;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _saveTokensToStorage(accessToken, refreshToken);
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _shouldShowWelcome = false;
    notifyListeners();
  }

  void markWelcomeShown() {
    _shouldShowWelcome = false;
    notifyListeners();
  }

  Future<LoginResult> loginWithResult(String userId, String password, String loginUrl) async {
    try {
      _logger.info('로그인 시도: $userId');
      final dio = DioClient().dio;

      final response = await dio.post(
        loginUrl,
        data: {
          'user_id': userId,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 응답 데이터 null 체크
        if (data == null) {
          _logger.warning('로그인 응답 데이터가 null입니다');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '서버 응답이 올바르지 않습니다.',
          );
        }

        // 필수 필드 존재 확인
        if (data['user'] == null || data['access_token'] == null || data['refresh_token'] == null) {
          _logger.warning('로그인 응답에 필수 필드가 누락됨: ${data.keys.toList()}');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '서버 응답 형식이 올바르지 않습니다.',
          );
        }

        try {
          _currentUser = User.fromJson(data['user']);
          _accessToken = data['access_token'];
          _refreshToken = data['refresh_token'];
          
          _logger.info('로그인 응답에서 받은 토큰 정보:');
          _logger.info('액세스 토큰 길이: ${_accessToken?.length}');
          _logger.info('리프레시 토큰 길이: ${_refreshToken?.length}');
          _logger.info('액세스 토큰 앞 20자: ${_accessToken?.substring(0, 20)}...');
          
          // 토큰 저장
          await _saveTokensToStorage(_accessToken!, _refreshToken!);
          
          // 저장 후 다시 확인
          final savedTokens = await _loadTokensFromStorage();
          _logger.info('저장 확인 - 액세스 토큰: ${savedTokens['access_token'] != null ? '저장됨' : '저장안됨'}');
          _logger.info('저장 확인 - 리프레시 토큰: ${savedTokens['refresh_token'] != null ? '저장됨' : '저장안됨'}');

          _shouldShowWelcome = true;
          notifyListeners();

          _logger.info('로그인 성공: ${_currentUser?.username}');
          return LoginResult(success: true, message: '로그인 성공');
        } catch (e) {
          _logger.warning('사용자 데이터 파싱 실패: $e');
          return LoginResult(
            success: false,
            errorType: LoginErrorType.serverError,
            message: '사용자 정보를 처리하는 중 오류가 발생했습니다.',
          );
        }
      } else {
        _logger.warning('로그인 실패: ${response.statusCode}');
        return LoginResult(
          success: false,
          errorType: LoginErrorType.invalidCredentials,
          message: '아이디 또는 비밀번호가 올바르지 않습니다.',
        );
      }
    } on DioException catch (e) {
      _logger.warning('로그인 Dio 에러: ${e.type} - ${e.message}');
      
      // 서버 연결 문제 구분
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.timeout,
          message: '서버 연결 시간이 초과되었습니다.',
        );
      }
      
      if (e.type == DioExceptionType.connectionError ||
          e.message?.contains('SocketException') == true ||
          e.message?.contains('Connection refused') == true ||
          e.message?.contains('Network is unreachable') == true) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.serverError,
          message: '서버에 연결할 수 없습니다.',
        );
      }
      
      if (e.response?.statusCode == 401) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.invalidCredentials,
          message: '아이디 또는 비밀번호가 올바르지 않습니다.',
        );
      }
      
      if (e.response?.statusCode == 429) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.rateLimited,
          message: '너무 많은 로그인 시도. 잠시 후 다시 시도해주세요.',
        );
      }
      
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return LoginResult(
          success: false,
          errorType: LoginErrorType.serverError,
          message: '서버에 오류가 발생했습니다.',
        );
      }
      
      return LoginResult(
        success: false,
        errorType: LoginErrorType.networkError,
        message: '네트워크 연결을 확인해주세요.',
      );
    } catch (e) {
      _logger.severe('예상치 못한 로그인 에러: $e');
      return LoginResult(
        success: false,
        errorType: LoginErrorType.unknown,
        message: '예상치 못한 오류가 발생했습니다.',
      );
    }
  }

  // 기존 login 메서드 (호환성 유지)
  Future<bool> login(String userId, String password, String loginUrl) async {
    final result = await loginWithResult(userId, password, loginUrl);
    return result.success;
  }

  Future<bool> signup({
    required String username,        // 사용자 이름/실명
    required String userId,          // 로그인용 아이디
    required String email,           // 이메일
    required String password,        // 비밀번호
    required String passwordConfirm, // 비밀번호 확인
    String? farmNickname,            // 목장 별명 (선택사항)
    required String signupUrl,
  }) async {
    try {
      final dio = DioClient().dio;

      final response = await dio.post(
        signupUrl,
        data: {
          'username': username,           // 사용자 이름/실명
          'user_id': userId,              // 로그인용 아이디
          'email': email,                 // 이메일
          'password': password,           // 비밀번호
          'password_confirm': passwordConfirm, // 비밀번호 확인
          'farm_nickname': farmNickname,  // 목장 별명 (선택사항)
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('✅ 회원가입 성공');
        return true;
      } else {
        _logger.warning('❌ 회원가입 실패: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      _logger.severe('❌ 회원가입 에러: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // 로그아웃 처리
  void logout() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _shouldShowWelcome = false;
    await _clearTokensFromStorage();
    notifyListeners();
    _logger.info('로그아웃: 모든 데이터 삭제됨');
  }

  // 토큰 저장 (access token과 refresh token 모두)
  Future<void> _saveTokensToStorage(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      
      // 사용자 정보도 함께 저장
      if (_currentUser != null) {
        final userJson = jsonEncode(_currentUser!.toJson());
        await prefs.setString('user_data', userJson);
        _logger.info('사용자 정보도 함께 저장됨');
      }
      
      _logger.info('토큰 저장 완료');
    } catch (e) {
      _logger.warning('토큰 저장 실패: $e');
    }
  }

  // 토큰 불러오기
  Future<Map<String, String?>> _loadTokensFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      return {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
    } catch (e) {
      _logger.warning('토큰 로드 실패: $e');
      return {
        'access_token': null,
        'refresh_token': null,
      };
    }
  }

  // 사용자 정보 로드
  Future<User?> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        final userJson = jsonDecode(userDataString) as Map<String, dynamic>;
        final user = User.fromJson(userJson);
        _logger.info('저장된 사용자 정보 로드 성공: ${user.username}');
        return user;
      }
      
      _logger.info('저장된 사용자 정보 없음');
      return null;
    } catch (e) {
      _logger.warning('사용자 정보 로드 실패: $e');
      return null;
    }
  }

  // 토큰 삭제
  Future<void> _clearTokensFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      _logger.info('토큰 및 사용자 정보 삭제 완료');
    } catch (e) {
      _logger.warning('토큰 삭제 실패: $e');
    }
  }

  // 토큰 갱신 (public wrapper)
  Future<bool> refreshAccessToken() async {
    return await _refreshAccessToken();
  }

  // 토큰 갱신 (private method)
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      _logger.warning('리프레시 토큰이 없습니다');
      return false;
    }

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      if (baseUrl.isEmpty) {
        _logger.warning('API_BASE_URL이 설정되지 않았습니다');
        return false;
      }

      final dio = DioClient().dio;
      final response = await dio.post(
        '$baseUrl/auth/refresh',
        data: {
          'refresh_token': _refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          _accessToken = data['access_token'];
          
          // 새로운 리프레시 토큰이 있으면 업데이트
          if (data['refresh_token'] != null) {
            _refreshToken = data['refresh_token'];
          }
          
          // 토큰 저장
          await _saveTokensToStorage(_accessToken!, _refreshToken!);
          
          _logger.info('토큰 갱신 성공');
          return true;
        }
      }
      
      _logger.warning('토큰 갱신 실패: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.warning('토큰 갱신 에러: $e');
      return false;
    }
  }

  // 자동 로그인 체크 (앱 시작 시)
  Future<bool> checkAutoLogin() async {
    try {
      _logger.info('==== 자동 로그인 확인 시작 ====');
      
      final tokens = await _loadTokensFromStorage();
      final accessToken = tokens['access_token'];
      final refreshToken = tokens['refresh_token'];
      
      _logger.info('저장된 액세스 토큰 존재: ${accessToken != null ? '예' : '아니오'}');
      _logger.info('저장된 리프레시 토큰 존재: ${refreshToken != null ? '예' : '아니오'}');
      
      if (accessToken != null && accessToken.isNotEmpty) {
        _logger.info('액세스 토큰 길이: ${accessToken.length}');
        _logger.info('액세스 토큰 앞 20자: ${accessToken.length > 20 ? accessToken.substring(0, 20) + '...' : accessToken}');
      }
      
      if (accessToken == null || accessToken.isEmpty) {
        _logger.info('저장된 액세스 토큰이 없습니다 - 자동 로그인 실패');
        return false;
      }

      // 토큰 설정
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      
      _logger.info('토큰 설정 완료 - 저장된 사용자 정보 로드 시도');
      
      // 저장된 사용자 정보 로드
      final savedUser = await _loadUserFromStorage();
      if (savedUser != null) {
        _currentUser = savedUser;
        _shouldShowWelcome = false;
        notifyListeners();
        _logger.info('==== 저장된 사용자 정보로 자동 로그인 성공 ====');
        return true;
      }
      
      _logger.info('저장된 사용자 정보가 없음 - 서버에서 사용자 정보 확인 시도');
      
      // 저장된 사용자 정보가 없으면 서버에서 확인
      if (await _validateTokenAndLoadUser()) {
        _logger.info('==== 서버 확인 후 자동 로그인 성공 ====');
        return true;
      }
      
      // 액세스 토큰이 만료된 경우 리프레시 토큰으로 갱신 시도
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        _logger.info('액세스 토큰 만료, 리프레시 토큰으로 갱신 시도');
        
        if (await _refreshAccessToken()) {
          // 토큰 갱신 성공 후 다시 사용자 정보 확인
          if (await _validateTokenAndLoadUser()) {
            _logger.info('==== 토큰 갱신 후 자동 로그인 성공 ====');
            return true;
          }
        } else {
          _logger.warning('토큰 갱신 실패');
        }
      } else {
        _logger.warning('리프레시 토큰이 없어서 토큰 갱신 불가');
      }
      
      // 모든 시도 실패 시 토큰 삭제
      _logger.warning('모든 자동 로그인 시도 실패 - 토큰 삭제');
      await _clearTokensFromStorage();
      _accessToken = null;
      _refreshToken = null;
      
      _logger.info('==== 자동 로그인 실패 ====');
      return false;
    } catch (e) {
      _logger.severe('자동 로그인 에러: $e');
      await _clearTokensFromStorage();
      _accessToken = null;
      _refreshToken = null;
      return false;
    }
  }

  // 토큰 유효성 검증 및 사용자 정보 로드
  Future<bool> _validateTokenAndLoadUser() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      _logger.info('API_BASE_URL: $baseUrl');
      
      if (baseUrl.isEmpty) {
        _logger.warning('API_BASE_URL이 설정되지 않았습니다 - 임시로 토큰만으로 자동 로그인 허용');
        // 임시: 토큰이 있으면 유효하다고 가정
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          _logger.info('토큰이 있으므로 임시로 자동 로그인 성공으로 처리');
          _shouldShowWelcome = false;
          notifyListeners();
          return true;
        }
        return false;
      }

      _logger.info('사용자 정보 요청 시작: $baseUrl/auth/me');
      _logger.info('사용할 토큰: Bearer ${_accessToken?.substring(0, 20)}...');

      final dio = DioClient().dio;
      
      try {
        final response = await dio.get(
          '$baseUrl/auth/me',
          options: Options(
            headers: {'Authorization': 'Bearer $_accessToken'},
          ),
        );

        _logger.info('사용자 정보 요청 응답 상태: ${response.statusCode}');
        _logger.info('응답 데이터: ${response.data}');

        if (response.statusCode == 200) {
          final userData = response.data;
          
          // 서버가 user 객체로 감싸서 반환하는 경우와 바로 반환하는 경우 모두 처리
          Map<String, dynamic> userInfo;
          if (userData['user'] != null) {
            // { user: {...} } 형태
            userInfo = userData['user'];
            _logger.info('user 객체로 감싸진 응답 형태');
          } else if (userData['id'] != null || userData['username'] != null) {
            // 바로 사용자 데이터 형태
            userInfo = userData;
            _logger.info('직접 사용자 데이터 응답 형태');
          } else {
            _logger.warning('응답에서 사용자 데이터를 찾을 수 없습니다: $userData');
            return false;
          }
          
          _currentUser = User.fromJson(userInfo);
          _shouldShowWelcome = false; // 자동 로그인 시에는 환영 메시지 표시 안함
          notifyListeners();
          
          _logger.info('사용자 정보 로드 성공: ${_currentUser?.username}');
          return true;
        } else {
          _logger.warning('사용자 정보 로드 실패: ${response.statusCode} - ${response.data}');
          return false;
        }
      } catch (dioError) {
        _logger.warning('/auth/me 엔드포인트 오류: $dioError');
        
        // 서버에 /auth/me 엔드포인트가 없을 경우 임시 대안
        if (dioError is DioException && dioError.response?.statusCode == 404) {
          _logger.info('/auth/me 엔드포인트가 없습니다. 토큰만으로 자동 로그인 시도');
          
          // 임시: 토큰이 있으면 유효하다고 가정하고 기본 사용자 정보 설정
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            // 기존에 저장된 사용자 정보가 있는지 확인
            if (_currentUser == null) {
              // 임시 사용자 정보 생성 (실제로는 다른 방법으로 사용자 정보를 가져와야 함)
              _logger.warning('임시 사용자 정보로 자동 로그인 처리');
            }
            _shouldShowWelcome = false;
            notifyListeners();
            return true;
          }
        }
        
        throw dioError;
      }
    } catch (e) {
      _logger.severe('사용자 정보 로드 에러: $e');
      if (e is DioException) {
        _logger.severe('DioException 상세: ${e.response?.statusCode} - ${e.response?.data}');
        _logger.severe('요청 URL: ${e.requestOptions.uri}');
        _logger.severe('요청 헤더: ${e.requestOptions.headers}');
      }
      return false;
    }
  }

  // 호환성을 위한 기존 메서드들
  Future<void> clearTokenFromStorage() async {
    await _clearTokensFromStorage();
  }

  Future<void> saveTokenToStorage(String token) async {
    // 기존 코드 호환성을 위해 유지하되, 새로운 방식 사용
    if (_refreshToken != null) {
      await _saveTokensToStorage(token, _refreshToken!);
    }
  }

  Future<String?> loadTokenFromStorage() async {
    final tokens = await _loadTokensFromStorage();
    return tokens['access_token'];
  }

  // 목장 이름 수정
  Future<bool> updateFarmName(String newFarmName) async {
    if (_accessToken == null) {
      _logger.warning('목장 이름 수정 실패: 로그인되지 않음');
      return false;
    }

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final dio = DioClient().dio;
      
      _logger.info('=== 목장 이름 수정 요청 시작 ===');
      _logger.info('새로운 목장 이름: $newFarmName');
      _logger.info('요청 데이터: ${{'farm_nickname': newFarmName}}');

      final response = await dio.put(
        '$baseUrl/auth/update-farm-name',
        data: {'farm_nickname': newFarmName},
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      _logger.info('=== 서버 응답 ===');
      _logger.info('상태 코드: ${response.statusCode}');
      _logger.info('응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.info('응답 데이터 타입: ${data.runtimeType}');
        _logger.info('success 값: ${data['success']}');
        _logger.info('user 데이터 존재: ${data['user'] != null}');
        
        if (data['success'] == true && data['user'] != null) {
          // 사용자 정보 업데이트
          _logger.info('사용자 정보 업데이트 전 목장명: ${_currentUser?.farmNickname}');
          _currentUser = User.fromJson(data['user']);
          _logger.info('사용자 정보 업데이트 후 목장명: ${_currentUser?.farmNickname}');
          notifyListeners();
          _logger.info('목장 이름 수정 성공: $newFarmName');
          return true;
        } else {
          _logger.warning('응답 구조 문제: success=${data['success']}, user=${data['user']}');
          return false;
        }
      }
      
      _logger.warning('목장 이름 수정 실패: ${response.statusCode} - ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.severe('=== Dio 에러 발생 ===');
      _logger.severe('에러 타입: ${e.type}');
      _logger.severe('에러 메시지: ${e.message}');
      _logger.severe('응답 상태코드: ${e.response?.statusCode}');
      _logger.severe('응답 데이터: ${e.response?.data}');
      return false;
    } catch (e) {
      _logger.severe('=== 예상치 못한 에러 ===');
      _logger.severe('에러: $e');
      return false;
    }
  }

  // 회원 탈퇴
  Future<bool> deleteAccount(String password) async {
    if (_accessToken == null) {
      _logger.warning('회원 탈퇴 실패: 로그인되지 않음');
      return false;
    }

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      final dio = DioClient().dio;
      
      _logger.info('=== 회원 탈퇴 요청 시작 ===');
      _logger.info('요청 데이터: password=[HIDDEN], confirmation=DELETE');

      final response = await dio.delete(
        '$baseUrl/auth/delete-account',
        data: {
          'password': password,
          'confirmation': 'DELETE',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      _logger.info('=== 서버 응답 ===');
      _logger.info('상태 코드: ${response.statusCode}');
      _logger.info('응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.info('success 값: ${data['success']}');
        
        if (data['success'] == true) {
          // 모든 사용자 데이터 삭제
          clearUser();
          await _clearTokensFromStorage();
          _logger.info('회원 탈퇴 성공');
          return true;
        } else {
          _logger.warning('탈퇴 실패: success=${data['success']}');
          return false;
        }
      }
      
      _logger.warning('회원 탈퇴 실패: ${response.statusCode} - ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.severe('=== 회원 탈퇴 Dio 에러 ===');
      _logger.severe('에러 타입: ${e.type}');
      _logger.severe('에러 메시지: ${e.message}');
      _logger.severe('응답 상태코드: ${e.response?.statusCode}');
      _logger.severe('응답 데이터: ${e.response?.data}');
      return false;
    } catch (e) {
      _logger.severe('=== 회원 탈퇴 예상치 못한 에러 ===');
      _logger.severe('에러: $e');
      return false;
    }
  }
}