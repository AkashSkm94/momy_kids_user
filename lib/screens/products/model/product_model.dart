import 'category_model.dart';
import 'product_image_model.dart';

class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final CategoryModel? category;
  final List<ProductImageModel> images;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse price
    double price = 0.0;
    if (json['price'] != null) {
      final priceStr = json['price'].toString();
      price = double.tryParse(priceStr) ?? 0.0;
    }

    // Parse category
    CategoryModel? category;
    if (json['category'] != null) {
      category = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    }

    // Parse images
    List<ProductImageModel> images = [];
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List)
          .map((img) => ProductImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    return ProductModel(
      id: json['id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      stock: json['stock'] as int? ?? 0,
      categoryId: json['category_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      category: category,
      images: images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'price': price.toStringAsFixed(2),
      'stock': stock,
      'category_id': categoryId,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category?.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
    };
  }

  // Get primary image URL or first image URL
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

  // Get category name
  String get categoryName {
    return category?.name ?? 'Uncategorized';
  }
}

