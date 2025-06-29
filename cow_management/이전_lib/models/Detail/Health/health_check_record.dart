// health_check_record.dart

class HealthCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String checkTime;
  final double bodyTemperature;
  final int heartRate;
  final int respiratoryRate;
  final double bodyConditionScore;
  final String udderCondition;
  final String hoofCondition;
  final String coatCondition;
  final String eyeCondition;
  final String noseCondition;
  final String appetite;
  final String activityLevel;
  final List<String> abnormalSymptoms;
  final String examiner;
  final String nextCheckDate;
  final String notes;

  HealthCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkTime = '',
    this.bodyTemperature = 0.0,
    this.heartRate = 0,
    this.respiratoryRate = 0,
    this.bodyConditionScore = 0.0,
    this.udderCondition = '',
    this.hoofCondition = '',
    this.coatCondition = '',
    this.eyeCondition = '',
    this.noseCondition = '',
    this.appetite = '',
    this.activityLevel = '',
    this.abnormalSymptoms = const [],
    this.examiner = '',
    this.nextCheckDate = '',
    this.notes = '',
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return value.split(',').map((e) => e.trim()).toList();
    return null;
  }

  factory HealthCheckRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ record_data, key_values 병합
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    // 🧷 cow_id, record_date 등도 병합
    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return HealthCheckRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      checkTime: data['check_time']?.toString() ?? '',
      bodyTemperature:
          _parseDouble(data['body_temperature'] ?? data['temperature']),
      heartRate: _parseInt(data['heart_rate']) ?? 0,
      respiratoryRate: _parseInt(data['respiratory_rate']) ?? 0,
      bodyConditionScore:
          _parseDouble(data['body_condition_score'] ?? data['bcs']),
      udderCondition: data['udder_condition']?.toString() ?? '',
      hoofCondition: data['hoof_condition']?.toString() ?? '',
      coatCondition: data['coat_condition']?.toString() ?? '',
      eyeCondition: data['eye_condition']?.toString() ?? '',
      noseCondition: data['nose_condition']?.toString() ?? '',
      appetite: data['appetite']?.toString() ?? '',
      activityLevel: data['activity_level']?.toString() ??
          data['activity']?.toString() ??
          '',
      abnormalSymptoms: _parseStringList(data['abnormal_symptoms']) ?? [],
      examiner: data['examiner']?.toString() ?? '',
      nextCheckDate: data['next_check_date']?.toString() ?? '',
      notes: data['notes']?.toString() ??
          safeJson['description']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '건강검진 기록',
        'description': notes.isNotEmpty ? notes : '건강검진 실시',
        'check_time': checkTime,
        'body_temperature': bodyTemperature,
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'body_condition_score': bodyConditionScore,
        'udder_condition': udderCondition,
        'hoof_condition': hoofCondition,
        'coat_condition': coatCondition,
        'eye_condition': eyeCondition,
        'nose_condition': noseCondition,
        'appetite': appetite,
        'activity_level': activityLevel,
        'abnormal_symptoms': abnormalSymptoms,
        'examiner': examiner,
        'next_check_date': nextCheckDate,
        'notes': notes,
      };
}
