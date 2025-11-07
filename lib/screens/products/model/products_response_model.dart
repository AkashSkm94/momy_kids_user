import 'pagination_model.dart';
import 'sorting_model.dart';
import 'product_model.dart';

class ProductsResponseModel {
  final PaginationModel pagination;
  final SortingModel sorting;
  final Map<String, dynamic> filters;
  final List<ProductModel> items;

  ProductsResponseModel({
    required this.pagination,
    required this.sorting,
    required this.filters,
    required this.items,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductsResponseModel(
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
      sorting: SortingModel.fromJson(json['sorting'] ?? {}),
      filters: json['filters'] ?? {},
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'sorting': sorting.toJson(),
      'filters': filters,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

