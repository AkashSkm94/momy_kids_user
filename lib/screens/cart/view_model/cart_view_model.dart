import 'package:flutter/material.dart';
import '../model/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel() {
    _loadInitialData();
  }

  final List<CartItemModel> _items = [];
  double _discount = 4.0;
  double _deliveryCharges = 2.0;

  List<CartItemModel> get items => List.unmodifiable(_items);

  double get discount => _discount;
  double get deliveryCharges => _deliveryCharges;

  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);

  double get total => subtotal - _discount + _deliveryCharges;

  bool get isEmpty => _items.isEmpty;

  void _loadInitialData() {
    _items
      ..clear()
      ..addAll([
        CartItemModel(
          id: '1',
          name: 'Rainbow Building Block',
          vendor: 'Toy World',
          price: 20.99,
          imageUrl:
              'https://images.unsplash.com/photo-1601758064083-3c28b80a39b1?auto=format&fit=crop&w=400&q=60',
          quantity: 2,
        ),
        CartItemModel(
          id: '2',
          name: 'Magnetic Drawing Board',
          vendor: 'Toy World',
          price: 34.99,
          imageUrl:
              'https://images.unsplash.com/photo-1528747045269-390fe33c19d0?auto=format&fit=crop&w=400&q=60',
          quantity: 1,
        ),
      ]);
  }

  void incrementQuantity(String id) {
    final item = _items.firstWhere((element) => element.id == id);
    item.quantity += 1;
    notifyListeners();
  }

  void decrementQuantity(String id) {
    final item = _items.firstWhere((element) => element.id == id);
    if (item.quantity > 1) {
      item.quantity -= 1;
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
}

