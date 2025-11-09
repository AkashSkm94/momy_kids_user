class Kid {
  String id;
  String name;
  String gender;
  DateTime? dateOfBirth;
  int age;

  Kid({
    required this.id,
    required this.name,
    required this.gender,
    this.dateOfBirth,
    int? age,
  }) : age = age ?? _calculateAgeNullable(dateOfBirth);

  // Static method to calculate age from date of birth
  static int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    int months = now.month - dateOfBirth.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    return years;
  }

  static int _calculateAgeNullable(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 0;
    return _calculateAge(dateOfBirth);
  }

  // Calculate age from date of birth
  String getAge() {
    if (dateOfBirth == null) {
      return '$age Years 0 Months';
    }
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    int months = now.month - dateOfBirth!.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years Years $months Months';
  }

  // Get age with translations
  String getAgeTranslated(String yearsText, String monthsText, String yearText, String monthText) {
    if (dateOfBirth == null) {
      final yearLabel = age == 1 ? yearText : yearsText;
      return '$age $yearLabel 0 $monthsText';
    }
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    int months = now.month - dateOfBirth!.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    final yearLabel = years == 1 ? yearText : yearsText;
    final monthLabel = months == 1 ? monthText : monthsText;

    return '$years $yearLabel $months $monthLabel';
  }

  // Convert to JSON for API request (for adding new kids)
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'age': age,
      'phoneNumber':"",
      'gender': gender.toLowerCase(),
      'birthDate': dateOfBirth == null ? "" : dateOfBirth?.toUtc().toIso8601String(),
    };
  }

  // Convert to JSON for API update request (includes ID)
  Map<String, dynamic> toUpdateApiJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'birthDate': dateOfBirth == null ? "" : dateOfBirth?.toUtc().toIso8601String(),
    };
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'date_of_birth': dateOfBirth == null ? "" : dateOfBirth?.toUtc().toIso8601String(),
      'age': age,
    };
  }

  // Create from JSON
  factory Kid.fromJson(Map<String, dynamic> json) {
    final String? birthDateStr = json['birthDate'] ?? json['date_of_birth'];
    DateTime? parsedDob;
    if (birthDateStr != null) {
      try {
        parsedDob = DateTime.parse(birthDateStr);
      } catch (_) {
        parsedDob = null;
      }
    }

    final int resolvedAge = (json['age'] is int)
        ? (json['age'] as int)
        : _calculateAgeNullable(parsedDob);

    return Kid(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: parsedDob,
      age: resolvedAge,
    );
  }

  // Create a copy with updated fields
  Kid copyWith({
    String? id,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
  }) {
    return Kid(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
    );
  }
}






