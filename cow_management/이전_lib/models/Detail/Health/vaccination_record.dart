class VaccinationRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? vaccinationTime;
  final String? vaccineName;
  final String? vaccineType;
  final String? vaccineBatch;
  final double? dosage;
  final String? injectionSite;
  final String? injectionMethod;
  final String? administrator;
  final String? vaccineManufacturer;
  final String? expiryDate;
  final bool? adverseReaction;
  final String? reactionDetails;
  final String? nextVaccinationDue;
  final int? cost;
  final String? notes;

  VaccinationRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.vaccinationTime,
    this.vaccineName,
    this.vaccineType,
    this.vaccineBatch,
    this.dosage,
    this.injectionSite,
    this.injectionMethod,
    this.administrator,
    this.vaccineManufacturer,
    this.expiryDate,
    this.adverseReaction,
    this.reactionDetails,
    this.nextVaccinationDue,
    this.cost,
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

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
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

    return VaccinationRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id']?.toString() ?? '',
      recordDate: data['record_date']?.toString() ?? '',
      vaccinationTime: data['vaccination_time']?.toString(),
      vaccineName:
          data['vaccine_name']?.toString() ?? data['vaccine']?.toString(),
      vaccineType: data['vaccine_type']?.toString(),
      vaccineBatch: data['vaccine_batch']?.toString(),
      dosage: _parseDouble(data['dosage']),
      injectionSite: data['injection_site']?.toString(),
      injectionMethod: data['injection_method']?.toString(),
      administrator: data['administrator']?.toString(),
      vaccineManufacturer: data['vaccine_manufacturer']?.toString(),
      expiryDate: data['expiry_date']?.toString(),
      adverseReaction: data['adverse_reaction'] is bool
          ? data['adverse_reaction']
          : (data['adverse_reaction']?.toString().toLowerCase() == 'true'),
      reactionDetails: data['reaction_details']?.toString(),
      nextVaccinationDue: data['next_vaccination_due']?.toString(),
      cost: _parseInt(data['cost']),
      notes: data['notes']?.toString() ??
          safeJson['description']?.toString() ??
          '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '백신 접종',
        'description': notes?.isNotEmpty == true ? notes : '백신 접종 기록',
        'vaccination_time': vaccinationTime,
        'vaccine_name': vaccineName,
        'vaccine_type': vaccineType,
        'vaccine_batch': vaccineBatch,
        'dosage': dosage,
        'injection_site': injectionSite,
        'injection_method': injectionMethod,
        'administrator': administrator,
        'vaccine_manufacturer': vaccineManufacturer,
        'expiry_date': expiryDate,
        'adverse_reaction': adverseReaction,
        'reaction_details': reactionDetails,
        'next_vaccination_due': nextVaccinationDue,
        'cost': cost,
        'notes': notes,
      };
}
