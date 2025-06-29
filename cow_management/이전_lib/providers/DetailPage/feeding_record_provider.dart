import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/feeding_record.dart';

class FeedingRecordProvider with ChangeNotifier {
  List<FeedingRecord> _records = [];

  List<FeedingRecord> get records => _records;

  Future<void> fetchRecords(String cowId, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) {
      print('⚠️ API_BASE_URL이 설정되지 않았습니다.');
      return;
    }

    try {
      print('🔄 사료급여 기록 조회 시작: $baseUrl/records/cow/$cowId/feed-records');
      
      final response = await dio.get(
        '$baseUrl/records/cow/$cowId/feed-records',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 사료급여 기록 조회 응답: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        _records.clear();
        
        if (response.data == null) {
          print('⚠️ 응답 데이터가 null입니다.');
          notifyListeners();
          return;
        }

        if (response.data is! List) {
          print('⚠️ 응답 데이터가 List 형태가 아닙니다: ${response.data.runtimeType}');
          notifyListeners();
          return;
        }

        final List<dynamic> dataList = response.data as List<dynamic>;
        print('📊 사료급여 기록 수: ${dataList.length}');

        int feedingCount = 0;
        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            try {
              // 전체 JSON을 그대로 전달 (key_values 포함)
              _records.add(FeedingRecord.fromJson(Map<String, dynamic>.from(item)));
              feedingCount++;
            } catch (e) {
              print('! 사료급여 기록 파싱 오류: $e');
              print('📄 문제가 된 데이터: $item');
            }
          }
        }
        
        print('✅ 사료급여 기록 필터링 완료: $feedingCount개');
        notifyListeners();
      } else {
        print('❌ 예상치 못한 응답 코드: ${response.statusCode}');
        throw Exception('사료급여 기록 조회 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 Dio 오류 발생:');
      print('   - 오류 타입: ${e.type}');
      print('   - 상태 코드: ${e.response?.statusCode}');
      print('   - 오류 메시지: ${e.message}');
      
      if (e.response?.statusCode == 500) {
        print('🚨 서버 내부 오류 (500): 백엔드 서버에 문제가 있습니다.');
        print('서버 응답: ${e.response?.data}');
        
        // 500 오류 시에도 빈 목록으로 처리하여 앱이 크래시되지 않도록 함
        _records.clear();
        notifyListeners();
        return;
      }
      
      if (e.response?.statusCode == 404) {
        print('📭 사료급여 기록이 없습니다 (404)');
        _records.clear();
        notifyListeners();
        return;
      }
      
      throw Exception('사료급여 기록 불러오기 실패: $e');
    } catch (e) {
      print('❌ 일반 오류: $e');
      throw Exception('사료급여 기록 불러오기 실패: $e');
    }
  }

  Future<bool> addRecord(FeedingRecord record, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.post(
        '$baseUrl/records/feed',
        data: record.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        _records.add(FeedingRecord.fromJson(response.data));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('사료 기록 추가 오류: $e');
    }
    return false;
  }

  Future<bool> deleteRecord(String id, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.delete(
        '$baseUrl/records/$id',  // 수정: 통일된 패턴 사용
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _records.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('사료 기록 삭제 오류: $e');
    }
    return false;
  }

  Future<bool> updateRecord(String id, FeedingRecord updated, String token) async {
    final dio = Dio();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null) return false;

    try {
      final response = await dio.put(
        '$baseUrl/records/$id',  // 수정: 통일된 패턴 사용
        data: {
          'record_date': updated.feedingDate,  // 수정: recordDate → feedingDate
          'record_data': updated.toJson(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final index = _records.indexWhere((r) => r.id == id);
        if (index != -1) {
          _records[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('사료급여 기록 수정 오류: $e');
    }
    return false;
  }
}
