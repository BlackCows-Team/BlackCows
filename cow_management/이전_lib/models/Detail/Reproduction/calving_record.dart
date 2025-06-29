class CalvingRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? calvingTime;
  final String? calvingDifficulty;
  final String? assistanceProvided;
  final int? calfCount;
  final String? calfGender;
  final double? calfWeight;
  final String? calfHealth;
  final String? placentaExpulsion;
  final String? complications;
  final String? veterinarian;
  final double? cost;
  final String? notes;

  CalvingRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.calvingTime,
    this.calvingDifficulty,
    this.assistanceProvided,
    this.calfCount,
    this.calfGender,
    this.calfWeight,
    this.calfHealth,
    this.placentaExpulsion,
    this.complications,
    this.veterinarian,
    this.cost,
    this.notes,
  });

  CalvingRecord copyWith({
    String? cowId,
    String? recordDate,
    String? calvingTime,
    String? calvingDifficulty,
    String? assistanceProvided,
    int? calfCount,
    String? calfGender,
    double? calfWeight,
    String? calfHealth,
    String? placentaExpulsion,
    String? complications,
    String? veterinarian,
    double? cost,
    String? notes,
  }) {
    return CalvingRecord(
      cowId: cowId ?? this.cowId,
      recordDate: recordDate ?? this.recordDate,
      calvingTime: calvingTime ?? this.calvingTime,
      calvingDifficulty: calvingDifficulty ?? this.calvingDifficulty,
      assistanceProvided: assistanceProvided ?? this.assistanceProvided,
      calfCount: calfCount ?? this.calfCount,
      calfGender: calfGender ?? this.calfGender,
      calfWeight: calfWeight ?? this.calfWeight,
      calfHealth: calfHealth ?? this.calfHealth,
      placentaExpulsion: placentaExpulsion ?? this.placentaExpulsion,
      complications: complications ?? this.complications,
      veterinarian: veterinarian ?? this.veterinarian,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
    );
  }

  factory CalvingRecord.fromJson(Map<String, dynamic> json) {
    return CalvingRecord(
      id: json['id'],
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      calvingTime: json['calving_time'],
      calvingDifficulty: json['calving_difficulty'],
      assistanceProvided: json['assistance_provided'],
      calfCount: json['calf_count']?.toInt(),
      calfGender: json['calf_gender'],
      calfWeight: json['calf_weight']?.toDouble(),
      calfHealth: json['calf_health'],
      placentaExpulsion: json['placenta_expulsion'],
      complications: json['complications'],
      veterinarian: json['veterinarian'],
      cost: json['cost']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'calving_time': calvingTime,
        'calving_difficulty': calvingDifficulty,
        'assistance_provided': assistanceProvided,
        'calf_count': calfCount,
        'calf_gender': calfGender,
        'calf_weight': calfWeight,
        'calf_health': calfHealth,
        'placenta_expulsion': placentaExpulsion,
        'complications': complications,
        'veterinarian': veterinarian,
        'cost': cost,
        'notes': notes,
      };
} 