class Kid {
  String id;
  String name;
  String gender;
  DateTime dateOfBirth;

  Kid({
    required this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
  });

  // Calculate age from date of birth
  String getAge() {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    int months = now.month - dateOfBirth.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    return '$years Years $months Months';
  }

  // Get age with translations
  String getAgeTranslated(String yearsText, String monthsText, String yearText, String monthText) {
    final now = DateTime.now();
    int years = now.year - dateOfBirth.year;
    int months = now.month - dateOfBirth.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    final yearLabel = years == 1 ? yearText : yearsText;
    final monthLabel = months == 1 ? monthText : monthsText;

    return '$years $yearLabel $months $monthLabel';
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
    };
  }

  // Create from JSON
  factory Kid.fromJson(Map<String, dynamic> json) {
    return Kid(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: DateTime.parse(json['date_of_birth']),
    );
  }

  // Create a copy with updated fields
  Kid copyWith({
    String? id,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    return Kid(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}

