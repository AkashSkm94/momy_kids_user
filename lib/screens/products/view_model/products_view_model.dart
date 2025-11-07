import 'package:flutter/material.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../model/product_model.dart';
import '../model/products_response_model.dart';
import '../model/pagination_model.dart';
import '../model/category_model.dart';

class ProductsViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingCategories = false;
  List<ProductModel> _products = [];
  List<CategoryModel> _categoryModels = [];
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 10;
  bool _hasMore = true;
  
  // Sorting
  String _sortField = 'created_at';
  String _sortDirection = 'DESC';
  
  // Error
  String _errorMessage = '';

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingCategories => _isLoadingCategories;
  List<ProductModel> get products => _products;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMore => _hasMore;
  String get errorMessage => _errorMessage;

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
      notifyListeners();
      loadProducts(reset: true);
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load products from API
  Future<void> loadProducts({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
      setLoading(true);
    } else {
      if (!_hasMore || _isLoadingMore) return;
      setLoadingMore(true);
    }

    try {
      // Build request body
      final requestBody = <String, dynamic>{
        'page': _currentPage,
        'limit': _limit,
        'sortField': _sortField,
        'sortDirection': _sortDirection,
        'is_active': true,
      };

      // Add search query if not empty
      if (_searchQuery.isNotEmpty) {
        requestBody['search'] = _searchQuery;
      }

      // Add category filter if not 'All'
      // When "All" is selected, we don't send category parameter (or send empty string)
      if (_selectedCategory != 'All' && _selectedCategory.isNotEmpty) {
        // Find the original category name (without capitalization) from models
        final categoryModel = _categoryModels.firstWhere(
          (cat) => _capitalizeFirst(cat.name) == _selectedCategory,
          orElse: () => CategoryModel(
            id: '',
            name: _selectedCategory,
            isActive: true,
          ),
        );
        requestBody['category'] = categoryModel.name; // Use original name for API
      }

      // Make API call
      final response = await ApiUtils.post(
        endpoint: UrlManager.productsGetAll,
        body: requestBody,
      );

      if (reset) {
        setLoading(false);
      } else {
        setLoadingMore(false);
      }

      if (response.isSuccess && response.data != null) {
        final productsResponse = ProductsResponseModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        
        // Update pagination info
        _currentPage = productsResponse.pagination.page;
        _totalPages = productsResponse.pagination.totalPages;
        _totalItems = productsResponse.pagination.total;
        _hasMore = productsResponse.pagination.hasMore;

        // Add products to list
        if (reset) {
          _products = productsResponse.items;
        } else {
          _products.addAll(productsResponse.items);
        }
        _errorMessage = '';
      } else {
        _errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to load products';
        if (reset && _products.isEmpty) {
          // Only show error if we have no products
        }
      }
    } catch (e) {
      if (reset) {
        setLoading(false);
      } else {
        setLoadingMore(false);
      }
      _errorMessage = 'Error: ${e.toString()}';
    }
    
    notifyListeners();
  }

  // Load more products (next page)
  Future<void> loadMore() async {
    if (_hasMore && !_isLoadingMore && !_isLoading) {
      _currentPage++;
      await loadProducts();
    }
  }

  // Refresh products (reset and reload)
  Future<void> refresh() async {
    _currentPage = 1;
    _products.clear();
    _hasMore = true;
    await loadProducts(reset: true);
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    _products.clear();
    _hasMore = true;
    await loadProducts(reset: true);
  }

  // Extract unique categories from products


  // Filter products by category and search (client-side filtering for display)
  List<ProductModel> get filteredProducts {
    return _products; // Server-side filtering is already applied
  }

  // Load categories from API
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      final response = await ApiUtils.get(
        endpoint: UrlManager.productsCategoryAll,
      );

      if (response.isSuccess && response.hasData) {
        final data = response.data;
        List<dynamic> categoriesList = [];
        
        // Handle different response structures
        if (data is List) {
          categoriesList = data;
        } else if (data is Map && data['data'] is List) {
          categoriesList = data['data'] as List;
        }

        // Parse categories
        _categoryModels = categoriesList
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .where((category) => category.isActive) // Only active categories
            .toList();

        // Extract category names and capitalize first letter
        final categoryNames = _categoryModels
            .map((category) => _capitalizeFirst(category.name))
            .toList();

        // Add "All" as first category
        _categories = ['All', ...categoryNames];
      } else {
        // If API fails, keep default "All" category
        _categories = ['All'];
      }
    } catch (e) {
      print('Error loading categories: $e');
      // If error, keep default "All" category
      _categories = ['All'];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Helper method to capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

