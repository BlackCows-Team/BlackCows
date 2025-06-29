import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cow_management/models/Detail/breeding_record.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BreedingRecordProvider with ChangeNotifier {
  final List<BreedingRecord> _records = [];

  List<BreedingRecord> get records => List.unmodifiable(_records);

  final Dio _dio = Dio();
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  Future<void> fetchRecords(String cowId, String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/records/cow/$cowId/breeding-records',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      print('🐮 응답 상태 코드: ${response.statusCode}');
      print('📦 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // 응답이 List인지 Map(data 속성 포함)인지 자동 판별
        final recordsJson = data is List
            ? data
            : (data is Map && data['data'] is List)
                ? data['data']
                : [];

        _records.clear();
        for (var json in recordsJson) {
          final record = BreedingRecord.fromJson(json);
          print('✅ record.id: ${record.id}');
          _records.add(record);
        }

        notifyListeners();
      } else {
        throw Exception('응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 번식 기록 불러오기 실패: $e');
      throw Exception('번식 기록 불러오기 실패: $e');
    }
  }

  Future<void> addRecord(BreedingRecord record, String token) async {
    try {
      final response = await _dio.post(
        '$baseUrl/records/breeding',
        data: record.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 201) {
        _records.add(record);
        notifyListeners();
      } else {
        throw Exception('번식 기록 추가 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 번식 기록 추가 실패: $e');
      throw Exception('번식 기록 추가 실패: $e');
    }
  }

  Future<void> updateRecord(String recordId, BreedingRecord record, String token) async {
    try {
      final response = await _dio.put(
        '$baseUrl/records/$recordId',
        data: record.toJson(),
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        final index = _records.indexWhere((r) => r.id == recordId);
        if (index != -1) {
          _records[index] = record;
          notifyListeners();
        }
      } else {
        throw Exception('번식 기록 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 번식 기록 수정 실패: $e');
      throw Exception('번식 기록 수정 실패: $e');
    }
  }

  Future<void> deleteRecord(String recordId, String token) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/records/$recordId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _records.removeWhere((r) => r.id == recordId);
        notifyListeners();
      } else {
        throw Exception('번식 기록 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 번식 기록 삭제 실패: $e');
      throw Exception('번식 기록 삭제 실패: $e');
    }
  }

  BreedingRecord? getById(String recordId) {
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
