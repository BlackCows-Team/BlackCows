import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/models/Detail/milking_record.dart';

class MilkingRecordProvider with ChangeNotifier {
  final List<MilkingRecord> _records = [];
  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  List<MilkingRecord> get records => List.unmodifiable(_records);
  Future<void> fetchRecords(String cowId, String token,
      {int limit = 50}) async {
    try {
      final url = '$baseUrl/records/cow/$cowId/milking-records';
      print('🛰️ 요청 URL: $url');
      print('🐮 cowId: $cowId');
      print('🪪 토큰: $token');

      final response = await _dio.get(
        url,
        queryParameters: {'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        _records.clear();

        for (var json in data) {
          _records.add(MilkingRecord.fromJson(json));
        }

        notifyListeners();
      }
    } catch (e) {
      print('❌ 에러 전체 출력: $e');
      throw Exception('📦 착유 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(MilkingRecord record, String token) async {
    final data = record.toJson();
    if (!data.containsKey('cow_id') || data['cow_id'] == null) {
      print('❌ cow_id가 누락되었습니다.');
      throw Exception('cow_id가 누락되었습니다.');
    }

    try {
      print('🔄 착유 기록 추가 시작: $baseUrl/records/milking');
      print('📄 전송 데이터: $data');

      final response = await _dio.post(
        '$baseUrl/records/milking',
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      print('✅ 착유 기록 추가 응답: ${response.statusCode}');
      print('📄 응답 데이터: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _records.add(record);
        notifyListeners();
      }
    } catch (e) {
      print('❌ 착유 기록 추가 실패: $e');
      throw Exception('착유 기록 추가 실패: $e');
    }
  }

  Future<void> updateRecord(
      String recordId, MilkingRecord updated, String token) async {
    try {
      final response = await _dio.put(
        '$baseUrl/records/$recordId',
        data: updated.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final index = _records.indexWhere((r) => r.id == recordId);
        if (index != -1) {
          _records[index] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      throw Exception('착유 기록 수정 실패: $e');
    }
  }

  Future<void> deleteRecord(String recordId, String token) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _records.removeWhere((r) => r.id == recordId);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('착유 기록 삭제 실패: $e');
    }
  }

  MilkingRecord? getById(String recordId) {
    try {
      return _records.firstWhere((r) => r.id == recordId);
    } catch (e) {
      return null;
    }
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}
