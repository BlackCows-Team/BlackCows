class FeedingRecord {
  final String id;
  final String cowId;
  final String feedingDate;
  final String feedType;
  final double amount;
  final String feedTime;
  final String? notes;

  FeedingRecord({
    required this.id,
    required this.cowId,
    required this.feedingDate,
    required this.feedType,
    required this.amount,
    required this.feedTime,
    this.notes,
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

  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 캐스팅
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    
    // 데이터 소스 우선순위: record_data > key_values > 기본 json
    Map<String, dynamic> data = {};
    
    // 기본 json 데이터 추가
    data.addAll(safeJson);
    
    // key_values가 있고 비어있지 않으면 사용 (서버 응답 형태)
    if (safeJson['key_values'] != null && safeJson['key_values'] is Map) {
      final keyValues = Map<String, dynamic>.from(safeJson['key_values']);
      
      // key_values가 비어있지 않은 경우에만 매핑
      if (keyValues.isNotEmpty) {
        // 백엔드 key_values 필드명에 맞게 매핑
        if (keyValues.containsKey('type')) {
          data['feed_type'] = keyValues['type'];
        }
        if (keyValues.containsKey('amount')) {
          // "25.5kg" 형태에서 숫자만 추출
          String amountStr = keyValues['amount'].toString();
          data['feed_amount'] = _parseDouble(amountStr.replaceAll('kg', ''));
        }
        if (keyValues.containsKey('feed_time')) {
          data['feed_time'] = keyValues['feed_time'];
        }
        if (keyValues.containsKey('notes')) {
          data['notes'] = keyValues['notes'];
        }
      }
    }
    
    // record_data가 있으면 우선적으로 사용 (Flutter에서 전송한 형태)
    if (safeJson['record_data'] != null && safeJson['record_data'] is Map) {
      final recordData = Map<String, dynamic>.from(safeJson['record_data']);
      data.addAll(recordData);
    }

    String recordDateStr;
    final recordDateRaw = safeJson['record_date'];
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    return FeedingRecord(
      id: safeJson['id']?.toString() ?? '',
      cowId: safeJson['cow_id']?.toString() ?? '',
      feedingDate: recordDateStr,
      feedType: data['feed_type']?.toString() ?? '사료',
      amount: _parseDouble(data['feed_amount'] ?? data['amount']), // 두 필드명 모두 지원
      feedTime: data['feed_time']?.toString() ?? '',
      notes: data['notes']?.toString() ?? 
             safeJson['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_type': 'feed',
      'cow_id': cowId,
      'record_date': feedingDate,
      'title': '사료급여 ($feedType ${amount}kg)',
      'description': notes,
      'record_data': {
        'feed_time': feedTime,
        'feed_type': feedType,
        'feed_amount': amount, // 백엔드 필드명에 맞게 수정
        'notes': notes,
      },
    };
  }
}
