import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/Health/weight_record_model.dart';

class WeightRecordProvider with ChangeNotifier {
  List<WeightRecord> _records = [];

  List<WeightRecord> get records => _records;

  Future<List<WeightRecord>> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) {
      print('⚠️ API_BASE_URL이 설정되지 않았습니다.');
      return [];
    }

    try {
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/weight-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 체중 기록 조회 성공: ${response.statusCode}');
      print('서버 응답: ${response.data}');

      if (response.data == null || response.data is! List) {
        print('⚠️ 서버 응답 데이터가 올바르지 않습니다.');
        return [];
      }

      _records.clear();

      final dataList = response.data as List;
      _records = dataList.where((json) {
        return json['record_type'] == 'weight';
      }).map((json) {
        return WeightRecord.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      print('✅ 파싱된 체중 기록 수: ${_records.length}');
      for (var record in _records) {
        print(
            '기록: 날짜=${record.recordDate}, 체중=${record.weight}kg, BCS=${record.bodyConditionScore}');
      }

      notifyListeners();
      return _records;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        print('서버 응답: ${e.response?.data}');
        _records = [];
        notifyListeners();
        return [];
      } else if (e.response?.statusCode == 404) {
        print('📭 체중 기록이 없습니다 (404)');
        _records = [];
        notifyListeners();
        return [];
      } else {
        print('❌ 체중 기록 불러오기 네트워크 오류: ${e.message}');
        return [];
      }
    } catch (e) {
      print('❌ 체중 기록 불러오기 예상치 못한 오류: $e');
      return [];
    }
  }

  Future<bool> addRecord(WeightRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/weight',
        data: record.toJson(), // ✅ 통일된 toJson 사용
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ 체중 기록 추가 성공: ${response.data}');
      if (response.statusCode == 201) {
        _records.add(WeightRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('❌ 체중 기록 추가 실패: $e');
    }

    return false;
  }
}
