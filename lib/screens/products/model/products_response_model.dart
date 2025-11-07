import 'pagination_model.dart';
import 'product_model.dart';

class ProductsResponseModel {
  final PaginationModel pagination;
  final Map<String, dynamic> sorting;
  final Map<String, dynamic> filters;
  final List<ProductModel> items;

  ProductsResponseModel({
    required this.pagination,
    required this.sorting,
    required this.filters,
    required this.items,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse pagination
    PaginationModel pagination = PaginationModel(
      page: 1,
      limit: 10,
      total: 0,
      totalPages: 1,
    );
    if (json['pagination'] != null) {
      pagination = PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    // Parse sorting
    Map<String, dynamic> sorting = {};
    if (json['sorting'] != null) {
      sorting = json['sorting'] as Map<String, dynamic>;
    }

    // Parse filters
    Map<String, dynamic> filters = {};
    if (json['filters'] != null) {
      filters = json['filters'] as Map<String, dynamic>;
    }

    // Parse items
    List<ProductModel> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProductsResponseModel(
      pagination: pagination,
      sorting: sorting,
      filters: filters,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'sorting': sorting,
      'filters': filters,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

