class CategoryModel {
  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.description,
    this.imageUrl,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}

