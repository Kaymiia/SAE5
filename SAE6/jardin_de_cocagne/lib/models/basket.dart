// lib/models/basket.dart
class Basket {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String weight;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BasketProduct> products;

  Basket({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.weight,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.products = const [],
  });

  factory Basket.fromMap(Map<String, dynamic> map, [List<BasketProduct> products = const []]) {
    return Basket(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'] ?? '',
      imageUrl: map['image_url'] ?? 'assets/images/placeholder.png',
      weight: map['weight'] ?? '',
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : DateTime.now(),
      updatedAt: map['updated_at'] != null 
        ? DateTime.parse(map['updated_at']) 
        : DateTime.now(),
      products: products,
    );
  }
}

class BasketProduct {
  final int id;
  final int productId;
  final String productName;
  final String category;
  final String unit;
  final double quantity;

  BasketProduct({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.unit,
    required this.quantity,
  });

  factory BasketProduct.fromMap(Map<String, dynamic> map) {
    return BasketProduct(
      id: map['id'],
      productId: map['product_id'],
      productName: map['name'],
      category: map['category'] ?? '',
      unit: map['unit'] ?? '',
      quantity: map['quantity'] ?? 0.0,
    );
  }
}