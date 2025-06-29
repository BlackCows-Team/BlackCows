import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Reproduction/estrus_record.dart';

class EstrusRecordProvider with ChangeNotifier {
  List<EstrusRecord> _records = [];

  List<EstrusRecord> get records => _records;

  Future<List<EstrusRecord>> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return [];

    try {
      print('🔄 발정 기록 조회 시작: $baseUrl/records/cow/$cowId/breeding-records');

      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 발정 기록 조회 응답: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📊 전체 번식 기록 수: ${data.length}');

        final estrusRecords = data
            .where((record) => record['record_type'] == 'estrus')
            .map((json) {
              try {
                // 전체 JSON을 그대로 전달 (key_values 포함)
                return EstrusRecord.fromJson(Map<String, dynamic>.from(json));
              } catch (e) {
                print('! 발정 기록 파싱 오류: $e');
                print('📄 문제가 된 데이터: $json');
                return null;
              }
            })
            .where((record) => record != null)
            .cast<EstrusRecord>()
            .toList();

        _records = estrusRecords;
        notifyListeners();

        print('📦 불러온 발정 기록 수: ${_records.length}');
        return _records;
      } else {
        print('❌ 발정 기록 조회 실패: 상태코드 ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ 발정 기록 조회 오류: $e');
      return [];
    }
  }

  // 선택: records 초기화 메서드 (필요 시)
  void clearRecords() {
    _records = [];
    notifyListeners();
  }

  Future<bool> addEstrusRecord(EstrusRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final requestData = {
        'cow_id': record.cowId,
        'record_date': record.recordDate,
        'title': '발정 기록',
        'description':
            record.notes?.isNotEmpty == true ? record.notes : '발정 발견',
        'record_data': record.toJson(),
      };

      print('🔄 발정 기록 저장 요청: $requestData');

      final response = await dio.post(
        '$baseUrl/records/estrus',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 발정 기록 저장 응답: ${response.statusCode}');

      if (response.statusCode == 201) {
        _records.add(EstrusRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 발정 기록 생성 실패: $e');
      return false;
    }
  }
}
