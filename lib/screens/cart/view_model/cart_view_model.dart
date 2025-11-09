import 'package:flutter/material.dart';
import '../../../core/network/apiutils.dart';
import '../../../core/network/url_manager.dart';
import '../model/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel();

  final List<CartItemModel> _items = [];
  double _discount = 0.0;
  double _deliveryCharges = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  List<CartItemModel> get items => List.unmodifiable(_items);
  double get discount => _discount;
  double get deliveryCharges => _deliveryCharges;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get totalItems =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);

  double get total => subtotal - _discount + _deliveryCharges;

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    _setLoading(true);
    _setError('');

    try {
      final response = await ApiUtils.get(endpoint: UrlManager.cartDetails);
      if (response.isSuccess && response.hasData) {
        final data = response.data['data'];
        if (data == null) {
          _setError('Cart data not found');
        } else {
          _parseCartData(data);
        }
      } else {
        _setError(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to load cart',
        );
      }
    } catch (e) {
      _setError('Failed to load cart: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void incrementQuantity(String id) {
    final itemIndex = _items.indexWhere((element) => element.id == id);
    if (itemIndex == -1) return;
    _items[itemIndex].quantity += 1;
    notifyListeners();
  }

  void decrementQuantity(String id) {
    final itemIndex = _items.indexWhere((element) => element.id == id);
    if (itemIndex == -1) return;
    if (_items[itemIndex].quantity > 1) {
      _items[itemIndex].quantity -= 1;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void applyDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  void updateDeliveryCharges(double value) {
    _deliveryCharges = value;
    notifyListeners();
  }

  void _parseCartData(Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>? ?? []);
    _items
      ..clear()
      ..addAll(items.map((item) => _mapCartItem(item)));

    final subtotalFromApi =
        (data['subtotal'] is num) ? (data['subtotal'] as num).toDouble() : null;
    final totalFromApi =
        (data['total'] is num) ? (data['total'] as num).toDouble() : null;

    final computedSubtotal = subtotal;
    _deliveryCharges = 0.0;

    if (subtotalFromApi != null && totalFromApi != null) {
      final difference = totalFromApi - computedSubtotal;
      _deliveryCharges = difference >= 0 ? difference : 0.0;
    }

    notifyListeners();
  }

  CartItemModel _mapCartItem(Map<String, dynamic> item) {
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final primaryImage = product['primary_image_url']?.toString();

    return CartItemModel(
      id: item['id']?.toString() ?? '',
      productId: item['productId']?.toString() ?? '',
      name: product['name']?.toString() ?? '',
      description: product['description']?.toString() ?? '',
      vendor: product['vendor_id']?.toString() ?? '',
      unitPrice: _parseToDouble(item['unit_price']),
      lineTotal: _parseToDouble(item['line_total']),
      imageUrl: primaryImage != null && primaryImage.isNotEmpty
          ? '${UrlManager.imageBaseUrl}$primaryImage'
          : '',
      quantity: item['quantity'] is int
          ? item['quantity'] as int
          : int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
    );
  }

  double _parseToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}

