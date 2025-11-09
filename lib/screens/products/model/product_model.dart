import 'category_model.dart';
import 'product_image_model.dart';

class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String soldBy;
  final int stock;
  final String categoryId;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final CategoryModel category;
  final List<ProductImageModel> images;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.soldBy,
    required this.stock,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      soldBy:  json['soldBy'] ?? "",
      stock: json['stock'] ?? 0,
      categoryId: json['category_id'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      category: CategoryModel.fromJson(json['category'] ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => ProductImageModel.fromJson(image))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'price': price.toString(),
      'stock': stock,
      'category_id': categoryId,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  // Helper getters
  String get categoryName => category.name;
  
  String? get primaryImageUrl {
    final primaryImage = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.isNotEmpty ? images.first : ProductImageModel(
        id: '',
        productId: id,
        imageUrl: '',
        isPrimary: false,
        createdAt: '',
      ),
    );
    return primaryImage.imageUrl.isNotEmpty ? primaryImage.imageUrl : null;
  }
}

