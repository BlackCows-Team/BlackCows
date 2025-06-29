class InseminationRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String? inseminationTime;
  final String? bullId;
  final String? bullBreed;
  final String? semenBatch;
  final String? semenQuality;
  final String? inseminationMethod;
  final String? technicianName;
  final String? cervixCondition;
  final double? successProbability;
  final String? pregnancyCheckScheduled;
  final double? cost;
  final String? notes;

  InseminationRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.inseminationTime,
    this.bullId,
    this.bullBreed,
    this.semenBatch,
    this.semenQuality,
    this.inseminationMethod,
    this.technicianName,
    this.cervixCondition,
    this.successProbability,
    this.pregnancyCheckScheduled,
    this.cost,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll('%', '').trim());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), ''));
  }

  static double? _parsePercentage(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll('%', '').trim());
  }

  static int? _extractNumber(dynamic value) {
    if (value == null) return null;
    final cleaned = value.toString().replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned);
  }

  factory InseminationRecord.fromJson(Map<String, dynamic> json) {
    final data = <String, dynamic>{};

    if (json['record_data'] != null && json['record_data'] is Map) {
      data.addAll(Map<String, dynamic>.from(json['record_data']));
    }
    if (json['key_values'] != null && json['key_values'] is Map) {
      data.addAll(Map<String, dynamic>.from(json['key_values']));
    }

    // 바깥 json도 병합
    data['cow_id'] = json['cow_id'];
    data['record_date'] = json['record_date'];

    return InseminationRecord(
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      inseminationTime: data['insemination_time']?.toString(),
      bullId: data['bull_id']?.toString(),
      bullBreed: data['bull_breed']?.toString() ?? data['bull']?.toString(),
      semenBatch: data['semen_batch']?.toString(),
      semenQuality:
          data['semen_quality']?.toString() ?? data['quality']?.toString(),
      technicianName:
          data['technician_name']?.toString() ?? data['technician']?.toString(),
      inseminationMethod:
          data['insemination_method']?.toString() ?? data['method']?.toString(),
      cervixCondition: data['cervix_condition']?.toString(),
      successProbability:
          _parseDouble(data['success_probability'] ?? data['success']),
      cost: (json['cost'] as num?)?.toDouble(),
      pregnancyCheckScheduled: data['pregnancy_check_scheduled']?.toString(),
      notes: data['notes']?.toString() ?? json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '인공수정 기록',
        'description': notes ?? '인공수정 실시',
        if (inseminationTime != null) 'insemination_time': inseminationTime,
        if (bullId != null) 'bull_id': bullId,
        if (bullBreed != null) 'bull_breed': bullBreed,
        if (semenBatch != null) 'semen_batch': semenBatch,
        if (semenQuality != null) 'semen_quality': semenQuality,
        if (inseminationMethod != null)
          'insemination_method': inseminationMethod,
        if (technicianName != null) 'technician_name': technicianName,
        if (cervixCondition != null) 'cervix_condition': cervixCondition,
        if (successProbability != null)
          'success_probability': successProbability,
        if (pregnancyCheckScheduled != null)
          'pregnancy_check_scheduled': pregnancyCheckScheduled,
        if (cost != null) 'cost': cost,
        if (notes != null) 'notes': notes,
      };
}
