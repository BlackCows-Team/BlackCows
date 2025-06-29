class BreedingRecord {
  final String id;
  final String cowId;
  final String recordType;
  final String recordDate;
  final String title;
  final String description;
  final String breedingMethod;
  final String breedingDate;
  final String bullInfo;
  final String expectedCalvingDate;
  final String pregnancyCheckDate;
  final String breedingResult;
  final int cost;
  final String veterinarian;

  BreedingRecord({
    required this.id,
    required this.cowId,
    required this.recordType,
    required this.recordDate,
    required this.title,
    required this.description,
    required this.breedingMethod,
    required this.breedingDate,
    required this.bullInfo,
    required this.expectedCalvingDate,
    required this.pregnancyCheckDate,
    required this.breedingResult,
    required this.cost,
    required this.veterinarian,
  });

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] ?? '',
      cowId: json['cow_id'] ?? '',
      recordType: json['record_type'] ?? 'breeding',
      recordDate: json['record_date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      breedingMethod: json['breeding_method'] ?? '',
      breedingDate: json['breeding_date'] ?? '',
      bullInfo: json['bull_info'] ?? '',
      expectedCalvingDate: json['expected_calving_date'] ?? '',
      pregnancyCheckDate: json['pregnancy_check_date'] ?? '',
      breedingResult: json['breeding_result'] ?? '',
      cost: json['cost'] ?? 0,
      veterinarian: json['veterinarian'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cow_id": cowId,
      "record_type": "breeding",
      "record_date": recordDate,
      "title": title,
      "description": description,
      "breeding_method": breedingMethod,
      "breeding_date": breedingDate,
      "bull_info": bullInfo,
      "expected_calving_date": expectedCalvingDate,
      "pregnancy_check_date": pregnancyCheckDate,
      "breeding_result": breedingResult,
      "cost": cost,
      "veterinarian": veterinarian,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      "title": title,
      "description": description,
      "breeding_method": breedingMethod,
      "breeding_date": breedingDate,
      "bull_info": bullInfo,
      "expected_calving_date": expectedCalvingDate,
      "pregnancy_check_date": pregnancyCheckDate,
      "breeding_result": breedingResult,
      "cost": cost,
      "veterinarian": veterinarian,
    };
  }
}
