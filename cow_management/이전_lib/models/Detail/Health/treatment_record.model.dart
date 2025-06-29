class TreatmentRecord {
  String? id;
  String cowId;
  String recordDate;
  String? treatmentTime;
  String? treatmentType;
  List<String>? symptoms;
  String? diagnosis;
  List<String>? medicationUsed;
  Map<String, String>? dosageInfo;
  String? treatmentMethod;
  int? treatmentDuration;
  String? veterinarian;
  String? treatmentResponse;
  String? sideEffects;
  bool? followUpRequired;
  String? followUpDate;
  int? treatmentCost;
  int? withdrawalPeriod;
  String? notes;

  TreatmentRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.treatmentTime,
    this.treatmentType,
    this.symptoms,
    this.diagnosis,
    this.medicationUsed,
    this.dosageInfo,
    this.treatmentMethod,
    this.treatmentDuration,
    this.veterinarian,
    this.treatmentResponse,
    this.sideEffects,
    this.followUpRequired,
    this.followUpDate,
    this.treatmentCost,
    this.withdrawalPeriod,
    this.notes,
  });

  factory TreatmentRecord.empty() {
    return TreatmentRecord(
      cowId: '',
      recordDate: '',
      treatmentTime: null,
      treatmentType: null,
      symptoms: null,
      diagnosis: null,
      medicationUsed: null,
      dosageInfo: null,
      treatmentMethod: null,
      treatmentDuration: null,
      veterinarian: null,
      treatmentResponse: null,
      sideEffects: null,
      followUpRequired: null,
      followUpDate: null,
      treatmentCost: null,
      withdrawalPeriod: null,
      notes: null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue);
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }

  static int? _extractNumber(dynamic value) {
    if (value == null) return null;
    final cleaned = value.toString().replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned);
  }

  factory TreatmentRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ record_data 병합
    if (safeJson['record_data'] != null && safeJson['record_data'] is Map) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }

    // ✅ key_values도 병합 (한글 key 대응)
    if (safeJson['key_values'] != null && safeJson['key_values'] is Map) {
      final kv = Map<String, dynamic>.from(safeJson['key_values']);
      data.addAll({
        'diagnosis': kv['진단명'],
        'treatment_method': kv['치료 방법'],
        'veterinarian': kv['수의사'],
        'medication_used': kv['투여 약물'] != null
            ? kv['투여 약물'].toString().split(',').map((e) => e.trim()).toList()
            : [],
        'treatment_cost': _extractNumber(kv['비용']),
        'follow_up_date': kv['추후 검사일'],
        'treatment_response': kv['치료 반응'],
        'side_effects': kv['부작용'],
        'notes': kv['비고'],
      });
    }

    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return TreatmentRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id']?.toString() ?? '',
      recordDate: data['record_date']?.toString() ?? '',
      treatmentTime: data['treatment_time']?.toString(),
      treatmentType: data['treatment_type']?.toString(),
      symptoms: _parseStringList(data['symptoms']),
      diagnosis: data['diagnosis']?.toString(),
      medicationUsed: data['medication_used'] != null
          ? List<String>.from(data['medication_used'])
          : [],
      dosageInfo: data['dosage_info'] != null && data['dosage_info'] is Map
          ? Map<String, String>.from((data['dosage_info'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString())))
          : {},
      treatmentMethod: data['treatment_method']?.toString(),
      treatmentDuration: _parseInt(data['treatment_duration']),
      veterinarian: data['veterinarian']?.toString(),
      treatmentResponse: data['treatment_response']?.toString(),
      sideEffects: data['side_effects']?.toString(),
      followUpRequired: data['follow_up_required'] == true ||
          data['follow_up_required']?.toString().toLowerCase() == 'true',
      followUpDate: data['follow_up_date']?.toString(),
      treatmentCost: _parseInt(data['treatment_cost']),
      withdrawalPeriod: _parseInt(data['withdrawal_period']),
      notes: data['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'record_type': 'treatment',
        'title': '치료 기록',
        'description': notes?.isNotEmpty == true ? notes : '치료 기록 등록',
        'treatment_time': treatmentTime,
        'treatment_type': treatmentType,
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        'medication_used': medicationUsed,
        'dosage_info': dosageInfo,
        'treatment_method': treatmentMethod,
        'treatment_duration': treatmentDuration,
        'veterinarian': veterinarian,
        'treatment_response': treatmentResponse,
        'side_effects': sideEffects,
        'follow_up_required': followUpRequired,
        'follow_up_date': followUpDate,
        'treatment_cost': treatmentCost,
        'withdrawal_period': withdrawalPeriod,
        'notes': notes,
      };
}
