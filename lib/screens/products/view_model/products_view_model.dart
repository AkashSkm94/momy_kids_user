import 'package:flutter/material.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../model/product_model.dart';
import '../model/products_response_model.dart';
import '../model/pagination_model.dart';

class ProductsViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<ProductModel> _products = [];
  
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
      if (_selectedCategory != 'All') {
        requestBody['category'] = _selectedCategory;
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
          response.data['data'] ?? {} as Map<String, dynamic>,
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

        // Extract categories from products
        _extractCategories();
        
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
  void _extractCategories() {
    final categorySet = <String>{'All'};
    for (var product in _products) {
      final categoryName = product.categoryName;
      if (categoryName.isNotEmpty && categoryName != 'Uncategorized') {
        categorySet.add(categoryName);
      }
    }
    _categories = categorySet.toList()..sort();
    if (!_categories.contains('All')) {
      _categories.insert(0, 'All');
    }
  }

  // Filter products by category and search (client-side filtering for display)
  List<ProductModel> get filteredProducts {
    return _products; // Server-side filtering is already applied
  }
}

