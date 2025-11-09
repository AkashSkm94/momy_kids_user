import 'package:flutter/material.dart';
import '../../../../core/network/apiutils.dart';
import '../../../../core/network/url_manager.dart';
import '../../model/product_model.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  ProductModel? _product;
  bool _isLoading = false;
  String _errorMessage = '';
  int _selectedImageIndex = 0;

  // Getters
  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get selectedImageIndex => _selectedImageIndex;

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setSelectedImageIndex(int index) {
    _selectedImageIndex = index;
    notifyListeners();
  }

  // Load product details
  Future<void> loadProductDetails(String productId) async {
    setLoading(true);
    setError('');

    try {
      // Replace {productId} in the endpoint
      final endpoint = UrlManager.productDetails.replaceAll('{productId}', productId);
      
      final response = await ApiUtils.get(
        endpoint: endpoint,
      );

      if (response.isSuccess && response.hasData) {
        final responseData = response.data;
        Map<String, dynamic> productData;
        
        // Handle different response structures
        if (responseData is Map && responseData['data'] != null) {
          productData = responseData['data'] as Map<String, dynamic>;
        } else {
          setError('Invalid product data format');
          setLoading(false);
          return;
        }

        _product = ProductModel.fromJson(productData);
        _errorMessage = '';
      } else {
        _errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to load product details';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }

  // Get current image URL
  String? getCurrentImageUrl() {
    if (_product == null || _product!.images.isEmpty) {
      return _product?.primaryImageUrl;
    }
    
    if (_selectedImageIndex >= 0 && _selectedImageIndex < _product!.images.length) {
      final image = _product!.images[_selectedImageIndex];
      return image.imageUrl.isNotEmpty ? image.imageUrl : null;
    }
    
    return _product?.primaryImageUrl;
  }

  // Get all image URLs
  List<String> getAllImageUrls() {
    if (_product == null) return [];
    
    if (_product!.images.isEmpty) {
      final primaryUrl = _product!.primaryImageUrl;
      return primaryUrl != null ? [primaryUrl] : [];
    }
    
    return _product!.images
        .map((img) => img.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();
  }
}




