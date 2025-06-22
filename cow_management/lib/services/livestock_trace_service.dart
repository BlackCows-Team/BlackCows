import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class LivestockTraceService {
  static final LivestockTraceService _instance = LivestockTraceService._internal();
  factory LivestockTraceService() => _instance;

  late final Dio dio;
  final _logger = Logger('LivestockTraceService');

  LivestockTraceService._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));
  }

  // 젖소 등록 상태 확인
  Future<String> checkRegistrationStatus(String earTagNumber, String token) async {
    try {
      final response = await dio.get(
        '/cows/registration-status/$earTagNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['status'] as String;
      } else {
        throw Exception('등록 상태 확인 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.severe('등록 상태 확인 오류: ${e.message}');
      if (e.response?.statusCode == 404) {
        return 'manual_registration_required';
      }
      rethrow;
    }
  }

  // 축산물이력제 기반 젖소 등록
  Future<Map<String, dynamic>> registerFromLivestockTrace(
    String earTagNumber,
    String cowName,
    String token,
  ) async {
    try {
      final response = await dio.post(
        '/cows/register-from-livestock-trace',
        data: {
          'ear_tag_number': earTagNumber,
          'user_provided_name': cowName,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('축산물이력제 등록 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.severe('축산물이력제 등록 오류: ${e.message}');
      throw Exception('축산물이력제 등록 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 축산물이력제 정보 조회
  Future<Map<String, dynamic>?> getLivestockTraceInfo(
    String earTagNumber,
    String token,
  ) async {
    try {
      final response = await dio.get(
        '/api/livestock-trace/livestock-trace/$earTagNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _logger.warning('축산물이력제 정보 조회 실패: ${e.message}');
      return null;
    }
  }

  // 빠른 기본 정보 확인
  Future<Map<String, dynamic>?> quickCheck(
    String earTagNumber,
    String token,
  ) async {
    try {
      final response = await dio.get(
        '/api/livestock-trace/livestock-quick-check/$earTagNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _logger.warning('빠른 확인 실패: ${e.message}');
      return null;
    }
  }
}