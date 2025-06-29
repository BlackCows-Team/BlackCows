import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class ErrorUtils {
  static final Logger _logger = Logger('ErrorUtils');

  /// 서버 연결 오류인지 확인하는 함수
  static bool isServerConnectionError(dynamic error) {
    // DioException 체크
    if (error is DioException) {
      // 연결 오류 타입들
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
      
      // 서버 오류 상태 코드들
      if (error.response?.statusCode != null && error.response!.statusCode! >= 500) {
        return true;
      }
      
      // 연결 관련 에러 메시지들
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('connection') ||
          message.contains('socket') ||
          message.contains('network') ||
          message.contains('timeout') ||
          message.contains('refused') ||
          message.contains('failed') ||
          message.contains('unreachable')) {
        return true;
      }
    }
    
    // ClientException 체크 (http 패키지)
    if (error.toString().contains('ClientException') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Network is unreachable') ||
        error.toString().contains('Write failed') ||
        error.toString().contains('원격 컴퓨터가 네트워크 연결을 거부') ||
        error.toString().contains('원격 호스트에 의해 강제로 끊겼습니다') ||
        error.toString().contains('connection error')) {
      return true;
    }
    
    return false;
  }

  /// 서버 연결 오류 발생 시 개발팀 문의 다이얼로그 표시
  static void showServerErrorDialog(BuildContext context, {String? customMessage}) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // 뒤로가기로 닫히지 않도록
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('서버 연결 오류'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '서버에 연결할 수 없습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (customMessage != null) ...[
                Text(
                  '오류 내용: $customMessage',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                '다음과 같은 문제일 수 있습니다:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text('• 서버가 일시적으로 중단됨'),
              const Text('• 네트워크 연결 문제'),
              const Text('• 서버 점검 중'),
              const Text('• 인터넷 연결 상태 확인 필요'),
              const SizedBox(height: 16),
              const Text(
                '문제가 지속되면 개발팀에 문의해주세요.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '개발팀 문의: support@blackcowsdairy.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _copyEmailToClipboard(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('이메일 복사'),
            ),
          ],
        );
      },
    );
  }

  /// 일반적인 오류를 처리하고 필요시 서버 오류 다이얼로그 표시
  static void handleError(BuildContext context, dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
    String defaultMessage = '오류가 발생했습니다',
  }) {
    _logger.severe('오류 처리: $error');
    
    if (!context.mounted) return;
    
    // 서버 연결 오류인 경우 다이얼로그 표시
    if (isServerConnectionError(error)) {
      showServerErrorDialog(context, customMessage: customMessage);
      return;
    }
    
    // 일반적인 오류인 경우 스낵바 표시
    if (showSnackBar) {
      final message = customMessage ?? defaultMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 이메일 주소 클립보드 복사
  static Future<void> _copyEmailToClipboard(BuildContext context) async {
    try {
      await Clipboard.setData(const ClipboardData(text: 'support@blackcowsdairy.com'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개발팀 이메일 주소가 클립보드에 복사되었습니다.\n이메일 앱에서 붙여넣기 하세요.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.warning('클립보드 복사 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복사에 실패했습니다. 수동으로 입력해주세요: support@blackcowsdairy.com'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// 서버 오류 메시지 추출
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        if (error.response!.data is Map && error.response!.data.containsKey('detail')) {
          return error.response!.data['detail'].toString();
        }
        if (error.response!.data is Map && error.response!.data.containsKey('message')) {
          return error.response!.data['message'].toString();
        }
      }
      return error.message ?? error.toString();
    }
    
    return error.toString();
  }
} 