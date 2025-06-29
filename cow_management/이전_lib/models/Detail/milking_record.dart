class MilkingRecord {
  final String id;
  final String cowId;
  final String recordDate;
  final double milkYield;
  final String milkingStartTime;
  final String milkingEndTime;
  final int milkingSession;
  final double conductivity;
  final int somaticCellCount;
  final bool bloodFlowDetected;
  final String colorValue;
  final double temperature;
  final double fatPercentage;
  final double proteinPercentage;
  final double airFlowValue;
  final int lactationNumber;
  final int ruminationTime;
  final String collectionCode;
  final int collectionCount;
  final String notes;

  MilkingRecord({
    required this.id,
    required this.cowId,
    required this.recordDate,
    required this.milkYield,
    required this.milkingStartTime,
    required this.milkingEndTime,
    required this.milkingSession,
    required this.conductivity,
    required this.somaticCellCount,
    required this.bloodFlowDetected,
    required this.colorValue,
    required this.temperature,
    required this.fatPercentage,
    required this.proteinPercentage,
    required this.airFlowValue,
    required this.lactationNumber,
    required this.ruminationTime,
    required this.collectionCode,
    required this.collectionCount,
    required this.notes,
  });

  // 문자열에서 숫자를 안전하게 추출하는 helper 함수
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // "41.0L", "12.5kg" 등의 단위가 포함된 문자열에서 숫자만 추출
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
      // 문자열에서 숫자만 추출
      String cleanValue = value.replaceAll(RegExp(r'[^\d-]'), '');
      return int.tryParse(cleanValue) ?? 0;
    }
    return 0;
  }

  factory MilkingRecord.fromJson(Map<String, dynamic> json) {
    final data = json['key_values'] ?? {};
    
    return MilkingRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      // 서버에서 실제로 보내는 필드들
      milkYield: _parseDouble(data['milk_yield']),
      milkingSession: _parseInt(data['session']), // 서버: "session"
      fatPercentage: _parseDouble(data['fat']), // 서버: "fat"
      
      // 서버에서 보내지 않는 필드들은 기본값 또는 빈 문자열
      milkingStartTime: data['milking_start_time'] ?? '',
      milkingEndTime: data['milking_end_time'] ?? '',
      conductivity: _parseDouble(data['conductivity']),
      somaticCellCount: _parseInt(data['somatic_cell_count']),
      bloodFlowDetected: data['blood_flow_detected'] ?? false,
      colorValue: data['color_value'] ?? '',
      temperature: _parseDouble(data['temperature']),
      proteinPercentage: _parseDouble(data['protein_percentage']),
      airFlowValue: _parseDouble(data['air_flow_value']),
      lactationNumber: _parseInt(data['lactation_number']),
      ruminationTime: _parseInt(data['rumination_time']),
      collectionCode: data['collection_code'] ?? '',
      collectionCount: _parseInt(data['collection_count']),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'milk_yield': milkYield,
        'milking_start_time': milkingStartTime,
        'milking_end_time': milkingEndTime,
        'milking_session': milkingSession,
        'conductivity': conductivity,
        'somatic_cell_count': somaticCellCount,
        'blood_flow_detected': bloodFlowDetected,
        'color_value': colorValue,
        'temperature': temperature,
        'fat_percentage': fatPercentage,
        'protein_percentage': proteinPercentage,
        'air_flow_value': airFlowValue,
        'lactation_number': lactationNumber,
        'rumination_time': ruminationTime,
        'collection_code': collectionCode,
        'collection_count': collectionCount,
        'notes': notes,
      };
}
