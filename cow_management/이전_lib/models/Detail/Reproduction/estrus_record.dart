class EstrusRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String? estrusStartTime;
  final String? estrusIntensity;
  final int? estrusDuration;
  final List<String>? behaviorSigns;
  final List<String>? visualSigns;
  final String? detectedBy;
  final String? detectionMethod;
  final String? nextExpectedEstrus;
  final bool? breedingPlanned;
  final String? notes;

  EstrusRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.estrusStartTime,
    this.estrusIntensity,
    this.estrusDuration,
    this.behaviorSigns,
    this.visualSigns,
    this.detectedBy,
    this.detectionMethod,
    this.nextExpectedEstrus,
    this.breedingPlanned,
    this.notes,
  });

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(clean);
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) return value.split(',').map((e) => e.trim()).toList();
    return null;
  }

  factory EstrusRecord.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    // ✅ 우선 record_data, key_values 다 병합
    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    // 🧷 여기에 cow_id, record_date 등도 병합
    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return EstrusRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      estrusStartTime: data['estrus_start_time'],
      estrusIntensity: data['estrus_intensity'] ?? data['intensity'],
      estrusDuration: _parseInt(data['estrus_duration'] ?? data['duration']),
      behaviorSigns: _parseStringList(data['behavior_signs']),
      visualSigns: _parseStringList(data['visual_signs']),
      detectedBy: data['detected_by'],
      detectionMethod: data['detection_method'],
      nextExpectedEstrus: data['next_expected_estrus'],
      breedingPlanned: data['breeding_planned'],
      notes: data['notes'] ?? safeJson['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '발정 기록',
        'description': notes ?? '발정 발견',
        'estrus_start_time': estrusStartTime,
        'estrus_intensity': estrusIntensity,
        'estrus_duration': estrusDuration,
        'behavior_signs': behaviorSigns,
        'visual_signs': visualSigns,
        'detected_by': detectedBy,
        'detection_method': detectionMethod,
        'next_expected_estrus': nextExpectedEstrus,
        'breeding_planned': breedingPlanned,
        'notes': notes,
      };
}
