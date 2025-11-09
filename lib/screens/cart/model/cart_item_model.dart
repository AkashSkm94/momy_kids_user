class CartItemModel {
  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.vendor,
    required this.unitPrice,
    required this.lineTotal,
    required this.imageUrl,
    required this.quantity,
  });

  final String id;
  final String productId;
  final String name;
  final String description;
  final String vendor;
  final double unitPrice;
  final double lineTotal;
  final String imageUrl;
  int quantity;

  double get total => unitPrice * quantity;
}

