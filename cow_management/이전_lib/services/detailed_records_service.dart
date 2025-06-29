import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class DetailedRecordsService {
  static final DetailedRecordsService _instance = DetailedRecordsService._internal();
  factory DetailedRecordsService() => _instance;

  late final Dio dio;
  final _logger = Logger('DetailedRecordsService');

  DetailedRecordsService._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));
  }

  // 착유 기록 생성
  Future<Map<String, dynamic>> createMilkingRecord({
    required String cowId,
    required String recordDate,
    required double milkYield,
    String? milkingStartTime,
    String? milkingEndTime,
    double? temperature,
    double? fatPercentage,
    double? proteinPercentage,
    int? somaticCellCount,
    double? conductivity,
    bool? bloodFlowDetected,
    String? colorValue,
    double? airFlowValue,
    int? lactationNumber,
    int? ruminationTime,
    String? collectionCode,
    int? collectionCount,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/milking',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          'milk_yield': milkYield,
          if (milkingStartTime != null) 'milking_start_time': milkingStartTime,
          if (milkingEndTime != null) 'milking_end_time': milkingEndTime,
          if (temperature != null) 'temperature': temperature,
          if (fatPercentage != null) 'fat_percentage': fatPercentage,
          if (proteinPercentage != null) 'protein_percentage': proteinPercentage,
          if (somaticCellCount != null) 'somatic_cell_count': somaticCellCount,
          if (conductivity != null) 'conductivity': conductivity,
          if (bloodFlowDetected != null) 'blood_flow_detected': bloodFlowDetected,
          if (colorValue != null) 'color_value': colorValue,
          if (airFlowValue != null) 'air_flow_value': airFlowValue,
          if (lactationNumber != null) 'lactation_number': lactationNumber,
          if (ruminationTime != null) 'rumination_time': ruminationTime,
          if (collectionCode != null) 'collection_code': collectionCode,
          if (collectionCount != null) 'collection_count': collectionCount,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('착유 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('착유 기록 생성 오류: ${e.message}');
      throw Exception('착유 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 발정 기록 생성
  Future<Map<String, dynamic>> createEstrusRecord({
    required String cowId,
    required String recordDate,
    String? estrusIntensity,
    int? durationHours,
    String? behaviorSigns,
    String? observedBy,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/estrus',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (estrusIntensity != null) 'estrus_intensity': estrusIntensity,
          if (durationHours != null) 'duration_hours': durationHours,
          if (behaviorSigns != null) 'behavior_signs': behaviorSigns,
          if (observedBy != null) 'observed_by': observedBy,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('발정 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('발정 기록 생성 오류: ${e.message}');
      throw Exception('발정 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 인공수정 기록 생성
  Future<Map<String, dynamic>> createInseminationRecord({
    required String cowId,
    required String recordDate,
    String? bullInfo,
    String? semenQuality,
    String? inseminationMethod,
    String? veterinarian,
    double? successProbability,
    String? expectedCalvingDate,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/insemination',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (bullInfo != null) 'bull_info': bullInfo,
          if (semenQuality != null) 'semen_quality': semenQuality,
          if (inseminationMethod != null) 'insemination_method': inseminationMethod,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (successProbability != null) 'success_probability': successProbability,
          if (expectedCalvingDate != null) 'expected_calving_date': expectedCalvingDate,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('인공수정 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('인공수정 기록 생성 오류: ${e.message}');
      throw Exception('인공수정 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 임신감정 기록 생성
  Future<Map<String, dynamic>> createPregnancyCheckRecord({
    required String cowId,
    required String recordDate,
    String? checkMethod,
    String? result,
    String? expectedCalvingDate,
    int? gestationDays,
    String? veterinarian,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/pregnancy-check',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (checkMethod != null) 'check_method': checkMethod,
          if (result != null) 'result': result,
          if (expectedCalvingDate != null) 'expected_calving_date': expectedCalvingDate,
          if (gestationDays != null) 'gestation_days': gestationDays,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('임신감정 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('임신감정 기록 생성 오류: ${e.message}');
      throw Exception('임신감정 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 분만 기록 생성
  Future<Map<String, dynamic>> createCalvingRecord({
    required String cowId,
    required String recordDate,
    String? calvingDifficulty,
    String? calvingSeason,
    String? calfGender,
    double? calfWeight,
    String? calfHealth,
    String? placentaExpulsion,
    String? complications,
    String? assistanceProvided,
    String? veterinarian,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/calving',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (calvingDifficulty != null) 'calving_difficulty': calvingDifficulty,
          if (calvingSeason != null) 'calving_season': calvingSeason,
          if (calfGender != null) 'calf_gender': calfGender,
          if (calfWeight != null) 'calf_weight': calfWeight,
          if (calfHealth != null) 'calf_health': calfHealth,
          if (placentaExpulsion != null) 'placenta_expulsion': placentaExpulsion,
          if (complications != null) 'complications': complications,
          if (assistanceProvided != null) 'assistance_provided': assistanceProvided,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('분만 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('분만 기록 생성 오류: ${e.message}');
      throw Exception('분만 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 사료급여 기록 생성
  Future<Map<String, dynamic>> createFeedRecord({
    required String cowId,
    required String recordDate,
    String? feedType,
    double? feedAmount,
    String? feedQuality,
    String? supplements,
    double? supplementAmount,
    String? feedingMethod,
    String? feedingTime,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/feed',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (feedType != null) 'feed_type': feedType,
          if (feedAmount != null) 'feed_amount': feedAmount,
          if (feedQuality != null) 'feed_quality': feedQuality,
          if (supplements != null) 'supplements': supplements,
          if (supplementAmount != null) 'supplement_amount': supplementAmount,
          if (feedingMethod != null) 'feeding_method': feedingMethod,
          if (feedingTime != null) 'feeding_time': feedingTime,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('사료급여 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('사료급여 기록 생성 오류: ${e.message}');
      throw Exception('사료급여 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 건강검진 기록 생성
  Future<Map<String, dynamic>> createHealthCheckRecord({
    required String cowId,
    required String recordDate,
    double? bodyTemperature,
    int? heartRate,
    int? respirationRate,
    double? bodyConditionScore,
    String? generalHealth,
    String? eyeCondition,
    String? noseCondition,
    String? mouthCondition,
    String? skinCondition,
    String? hoofCondition,
    String? veterinarian,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/health-check',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (bodyTemperature != null) 'body_temperature': bodyTemperature,
          if (heartRate != null) 'heart_rate': heartRate,
          if (respirationRate != null) 'respiration_rate': respirationRate,
          if (bodyConditionScore != null) 'body_condition_score': bodyConditionScore,
          if (generalHealth != null) 'general_health': generalHealth,
          if (eyeCondition != null) 'eye_condition': eyeCondition,
          if (noseCondition != null) 'nose_condition': noseCondition,
          if (mouthCondition != null) 'mouth_condition': mouthCondition,
          if (skinCondition != null) 'skin_condition': skinCondition,
          if (hoofCondition != null) 'hoof_condition': hoofCondition,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('건강검진 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('건강검진 기록 생성 오류: ${e.message}');
      throw Exception('건강검진 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 백신접종 기록 생성
  Future<Map<String, dynamic>> createVaccinationRecord({
    required String cowId,
    required String recordDate,
    String? vaccineName,
    String? vaccineType,
    double? dosage,
    String? administrationRoute,
    String? batchNumber,
    String? expirationDate,
    String? veterinarian,
    String? sideEffects,
    String? nextVaccinationDate,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/vaccination',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (vaccineName != null) 'vaccine_name': vaccineName,
          if (vaccineType != null) 'vaccine_type': vaccineType,
          if (dosage != null) 'dosage': dosage,
          if (administrationRoute != null) 'administration_route': administrationRoute,
          if (batchNumber != null) 'batch_number': batchNumber,
          if (expirationDate != null) 'expiration_date': expirationDate,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (sideEffects != null) 'side_effects': sideEffects,
          if (nextVaccinationDate != null) 'next_vaccination_date': nextVaccinationDate,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('백신접종 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('백신접종 기록 생성 오류: ${e.message}');
      throw Exception('백신접종 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 체중측정 기록 생성
  Future<Map<String, dynamic>> createWeightRecord({
    required String cowId,
    required String recordDate,
    double? weight,
    String? measurementMethod,
    double? chestGirth,
    double? bodyLength,
    double? hipHeight,
    double? bodyConditionScore,
    double? growthRate,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/weight',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (weight != null) 'weight': weight,
          if (measurementMethod != null) 'measurement_method': measurementMethod,
          if (chestGirth != null) 'chest_girth': chestGirth,
          if (bodyLength != null) 'body_length': bodyLength,
          if (hipHeight != null) 'hip_height': hipHeight,
          if (bodyConditionScore != null) 'body_condition_score': bodyConditionScore,
          if (growthRate != null) 'growth_rate': growthRate,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('체중측정 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('체중측정 기록 생성 오류: ${e.message}');
      throw Exception('체중측정 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 치료 기록 생성
  Future<Map<String, dynamic>> createTreatmentRecord({
    required String cowId,
    required String recordDate,
    String? diagnosis,
    String? symptoms,
    String? treatmentType,
    String? medicationUsed,
    double? dosage,
    String? administrationRoute,
    int? treatmentDuration,
    String? veterinarian,
    String? treatmentResult,
    double? cost,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/records/treatment',
        data: {
          'cow_id': cowId,
          'record_date': recordDate,
          if (diagnosis != null) 'diagnosis': diagnosis,
          if (symptoms != null) 'symptoms': symptoms,
          if (treatmentType != null) 'treatment_type': treatmentType,
          if (medicationUsed != null) 'medication_used': medicationUsed,
          if (dosage != null) 'dosage': dosage,
          if (administrationRoute != null) 'administration_route': administrationRoute,
          if (treatmentDuration != null) 'treatment_duration': treatmentDuration,
          if (veterinarian != null) 'veterinarian': veterinarian,
          if (treatmentResult != null) 'treatment_result': treatmentResult,
          if (cost != null) 'cost': cost,
          if (notes != null) 'notes': notes,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('치료 기록 생성 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('치료 기록 생성 오류: ${e.message}');
      throw Exception('치료 기록 생성 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 젖소별 전체 기록 조회
  Future<List<Map<String, dynamic>>> getCowRecords(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('기록 조회 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('기록 조회 오류: ${e.message}');
      throw Exception('기록 조회 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 젖소별 착유 기록 조회
  Future<List<Map<String, dynamic>>> getCowMilkingRecords(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/milking',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('착유 기록 조회 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('착유 기록 조회 오류: ${e.message}');
      throw Exception('착유 기록 조회 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 젖소별 건강 기록 조회
  Future<List<Map<String, dynamic>>> getCowHealthRecords(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/health-records',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('건강 기록 조회 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('건강 기록 조회 오류: ${e.message}');
      throw Exception('건강 기록 조회 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 젖소별 번식 기록 조회
  Future<List<Map<String, dynamic>>> getCowBreedingRecords(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/breeding-records',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('번식 기록 조회 실패: ${response.statusCode}');
      }
    } on DioError catch (e) {
      _logger.severe('번식 기록 조회 오류: ${e.message}');
      throw Exception('번식 기록 조회 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 기록 삭제
  Future<bool> deleteRecord(String recordId, String token) async {
    try {
      final response = await dio.delete(
        '/records/$recordId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioError catch (e) {
      _logger.severe('기록 삭제 오류: ${e.message}');
      throw Exception('기록 삭제 실패: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // 착유 통계 조회
  Future<Map<String, dynamic>?> getMilkingStatistics(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/milking/statistics',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      _logger.warning('착유 통계 조회 실패: ${e.message}');
      return null;
    }
  }

  // 체중 변화 추이 조회
  Future<Map<String, dynamic>?> getWeightTrend(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/weight/trend',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      _logger.warning('체중 변화 추이 조회 실패: ${e.message}');
      return null;
    }
  }

  // 번식 타임라인 조회
  Future<Map<String, dynamic>?> getReproductionTimeline(String cowId, String token) async {
    try {
      final response = await dio.get(
        '/records/cow/$cowId/reproduction/timeline',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      _logger.warning('번식 타임라인 조회 실패: ${e.message}');
      return null;
    }
  }
}