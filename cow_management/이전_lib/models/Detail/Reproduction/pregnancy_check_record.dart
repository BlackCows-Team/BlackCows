class PregnancyCheckRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? checkMethod;
  final String? checkResult;
  final String? expectedCalvingDate;
  final int? pregnancyDays;
  final String? veterinarian;
  final double? cost;
  final String? notes;

  PregnancyCheckRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.checkMethod,
    this.checkResult,
    this.expectedCalvingDate,
    this.pregnancyDays,
    this.veterinarian,
    this.cost,
    this.notes,
  });

  PregnancyCheckRecord copyWith({
    String? cowId,
    String? recordDate,
    String? checkMethod,
    String? checkResult,
    String? expectedCalvingDate,
    int? pregnancyDays,
    String? veterinarian,
    double? cost,
    String? notes,
  }) {
    return PregnancyCheckRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      checkMethod: checkMethod ?? this.checkMethod,
      checkResult: checkResult ?? this.checkResult,
      expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
      pregnancyDays: pregnancyDays ?? this.pregnancyDays,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), ''));
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll(RegExp(r'[^\d.]'), ''));
  }

  factory PregnancyCheckRecord.fromRecordDataJson(
    Map<String, dynamic> json, {
    required String cowId,
    required String recordDate,
    String? id,
  }) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ record_data, key_values 병합
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    // 🧷 cow_id, record_date 병합
    data['cow_id'] = cowId;
    data['record_date'] = recordDate;

    return PregnancyCheckRecord(
      id: id,
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      checkMethod: data['check_method']?.toString(),
      checkResult: data['check_result']?.toString(),
      expectedCalvingDate: data['expected_calving_date']?.toString(),
      pregnancyDays: _parseInt(data['pregnancy_days']),
      veterinarian: data['veterinarian']?.toString(),
      cost: _parseDouble(data['cost']),
      notes: data['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'check_method': checkMethod,
        'check_result': checkResult,
        'expected_calving_date': expectedCalvingDate,
        'pregnancy_days': pregnancyDays,
        'veterinarian': veterinarian,
        'cost': cost,
        'notes': notes,
      };
}
