class WeightRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? measurementTime;
  final double? weight;
  final String? measurementMethod;
  final double? bodyConditionScore;
  final double? heightWithers;
  final double? bodyLength;
  final double? chestGirth;
  final double? growthRate;
  final double? targetWeight;
  final String? weightCategory;
  final String? measurer;
  final String? notes;

  WeightRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.measurementTime,
    this.weight,
    this.measurementMethod,
    this.bodyConditionScore,
    this.heightWithers,
    this.bodyLength,
    this.chestGirth,
    this.growthRate,
    this.targetWeight,
    this.weightCategory,
    this.measurer,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    final data = <String, dynamic>{};

    // record_data → key_values → safeJson 순서로 병합
    if (safeJson['record_data'] != null && safeJson['record_data'] is Map) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null && safeJson['key_values'] is Map) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }
    data.addAll(safeJson);

    final recordDateRaw = data['record_date'];
    String recordDateStr;
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    return WeightRecord(
      id: data['id']?.toString(),
      cowId: data['cow_id']?.toString() ?? '',
      recordDate: recordDateStr,
      measurementTime: data['measurement_time']?.toString(),
      weight: _parseDouble(data['weight']),
      measurementMethod: data['measurement_method']?.toString(),
      bodyConditionScore:
          _parseDouble(data['body_condition_score'] ?? data['bcs']),
      heightWithers: _parseDouble(data['height_withers']),
      bodyLength: _parseDouble(data['body_length']),
      chestGirth: _parseDouble(data['chest_girth']),
      growthRate: _parseDouble(data['growth_rate']),
      targetWeight: _parseDouble(data['target_weight']),
      weightCategory: data['weight_category']?.toString(),
      measurer: data['measurer']?.toString(),
      notes: data['notes']?.toString() ?? data['description']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '체중 측정',
        'description': notes?.isNotEmpty == true ? notes : '체중 측정 기록',
        'measurement_time': measurementTime,
        'weight': weight,
        'measurement_method': measurementMethod,
        'body_condition_score': bodyConditionScore,
        'height_withers': heightWithers,
        'body_length': bodyLength,
        'chest_girth': chestGirth,
        'growth_rate': growthRate,
        'target_weight': targetWeight,
        'weight_category': weightCategory,
        'measurer': measurer,
        'notes': notes,
      };
}
