class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.vendor,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final String vendor;
  final double price;
  final String imageUrl;
  int quantity;

  double get total => price * quantity;
}

