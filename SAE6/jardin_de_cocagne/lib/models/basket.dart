// lib/models/basket.dart
import 'package:jardin_de_cocagne/models/basket_product.dart';

class Basket {
  final String id; // ID sous forme de chaîne de caractères
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String weight;
  final List<BasketProduct> products;

  Basket({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.weight,
    required this.products,
  });

  // Méthode pour obtenir l'ID sous forme d'entier
  int get idAsInt {
    return int.tryParse(id) ?? 0;
  }

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'].toString(), // Convertir en chaîne de caractères
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      weight: json['weight'] ?? '',
      products: json['products'] != null
          ? List<BasketProduct>.from(
              json['products'].map((product) => BasketProduct.fromJson(product)))
          : [],
    );
  }
}