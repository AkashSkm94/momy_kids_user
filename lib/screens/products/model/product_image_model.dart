class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isPrimary;
  final String createdAt;

  ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isPrimary,
    required this.createdAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'created_at': createdAt,
    };
  }
}

