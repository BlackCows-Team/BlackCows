import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Reproduction/insemination_record.dart';

class InseminationRecordProvider with ChangeNotifier {
  List<InseminationRecord> _records = [];

  List<InseminationRecord> get records => _records;

  Future<List<InseminationRecord>> fetchRecords(
      String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return [];

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('[🐮 DEBUG] Response status: ${response.statusCode}');
      print('[🐮 DEBUG] Response data: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final inseminationRecords = data
            .where((record) => record['record_type'] == 'insemination')
            .map((json) {
              try {
                return InseminationRecord.fromJson(
                    Map<String, dynamic>.from(json));
              } catch (e) {
                print('! 인공수정 파싱 오류: $e');
                print('📄 문제가 된 데이터: $json');
                return null;
              }
            })
            .where((record) => record != null)
            .cast<InseminationRecord>()
            .toList();

        _records = inseminationRecords;
        notifyListeners();

        debugPrint('📦 불러온 인공수정 기록 수: ${_records.length}');
        return _records;
      } else {
        debugPrint('인공수정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('인공수정 기록 조회 오류: $e');
      return [];
    }
  }

  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addInseminationRecord(
      InseminationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final requestData = record.toJson(); // ✅ 핵심 수정 포인트

      final response = await dio.post(
        '$baseUrl/records/insemination',
        data: requestData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('🔄 인공수정 기록 저장 요청: $requestData');
      print('✅ 인공수정 기록 저장 응답: ${response.statusCode}');

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('인공수정 기록 생성 실패: $e');
      return false;
    }
  }

  Future<bool> updateRecord(
      String recordId, InseminationRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.put(
        '$baseUrl/records/$recordId',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('인공수정 기록 수정 실패: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String recordId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('인공수정 기록 삭제 실패: $e');
      return false;
    }
  }
}
