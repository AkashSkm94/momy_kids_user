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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      parentId: json['parent_id'],
      description: json['description'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? false,
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

