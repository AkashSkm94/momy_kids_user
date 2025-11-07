class SortingModel {
  final String fieldName;
  final String direction;

  SortingModel({
    required this.fieldName,
    required this.direction,
  });

  factory SortingModel.fromJson(Map<String, dynamic> json) {
    return SortingModel(
      fieldName: json['fieldName'] ?? 'created_at',
      direction: json['direction'] ?? 'DESC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'direction': direction,
    };
  }
}

