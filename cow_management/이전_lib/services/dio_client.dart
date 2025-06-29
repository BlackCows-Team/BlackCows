import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final _logger = Logger('DioClient');
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  DioClient._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.path.contains('/auth/login') && 
            !options.path.contains('/auth/register') &&
            !options.path.contains('/auth/refresh') &&
            !options.path.contains('/sns/')) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        return handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.response?.statusCode == 401 && 
            !e.requestOptions.path.contains('/auth/login') &&
            !e.requestOptions.path.contains('/auth/register') &&
            !e.requestOptions.path.contains('/auth/refresh') &&
            !e.requestOptions.path.contains('/sns/')) {
          
          _logger.info('401 에러 감지 - 토큰 갱신 시도');
          
          if (!_isRefreshing) {
            _isRefreshing = true;
            
            try {
              final refreshSuccess = await _refreshToken();
              _isRefreshing = false;
              
              if (refreshSuccess) {
                _logger.info('토큰 갱신 성공 - 원래 요청 재시도');
                
                final prefs = await SharedPreferences.getInstance();
                final newToken = prefs.getString('access_token');
                
                if (newToken != null) {
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  
                  final response = await dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                }
              } else {
                _logger.warning('토큰 갱신 실패 - 로그아웃 처리 필요');
                await _clearTokens();
              }
            } catch (refreshError) {
              _isRefreshing = false;
              _logger.severe('토큰 갱신 중 에러 발생: $refreshError');
              await _clearTokens();
            }
          } else {
            await _waitForRefresh();
            
            final prefs = await SharedPreferences.getInstance();
            final newToken = prefs.getString('access_token');
            
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          }
        }
        
        if (e.type == DioExceptionType.connectionTimeout) {
          _logger.warning('연결 타임아웃: ${e.requestOptions.uri}');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          _logger.warning('응답 타임아웃: ${e.requestOptions.uri}');
        } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          _logger.severe('서버 에러 (${e.response!.statusCode}): ${e.requestOptions.uri}');
        }
        
        return handler.next(e);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.warning('리프레시 토큰이 없습니다');
        return false;
      }

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['access_token'] != null) {
          await prefs.setString('access_token', data['access_token']);
          
          if (data['refresh_token'] != null) {
            await prefs.setString('refresh_token', data['refresh_token']);
          }
          
          _logger.info('토큰 갱신 성공');
          return true;
        }
      }
      
      _logger.warning('토큰 갱신 실패: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.severe('토큰 갱신 에러: $e');
      return false;
    }
  }

  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      _logger.info('토큰 삭제 완료');
    } catch (e) {
      _logger.warning('토큰 삭제 실패: $e');
    }
  }

  Future<void> _waitForRefresh() async {
    int attempts = 0;
    const maxAttempts = 50;
    
    while (_isRefreshing && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }
}
