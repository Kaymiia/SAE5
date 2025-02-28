// lib/models/basket_product.dart
class BasketProduct {
  final int? id;
  final int? productId;
  final String? productName;
  final double quantity;
  final String? unit;
  final String? category;

  BasketProduct({
    this.id,
    this.productId,
    this.productName,
    required this.quantity,
    this.unit,
    this.category,
  });

  factory BasketProduct.fromJson(Map<String, dynamic> json) {
    return BasketProduct(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'],
      category: json['category'],
    );
  }
}