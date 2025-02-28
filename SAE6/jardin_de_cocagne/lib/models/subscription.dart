// lib/models/subscription.dart
class Subscription {
  final String id;
  final int userId; // Renommé pour cohérence avec l'API
  final int basketId;
  final String basketName;
  final int deliveryPointId;
  final String deliveryPointName;
  final String status;
  final String frequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double price;
  final String? weight;
  final String? imageUrl;
  final String routeName;
  
  Subscription({
    required this.id,
    required this.userId, // Renommé
    required this.basketId,
    required this.basketName,
    required this.deliveryPointId,
    required this.deliveryPointName,
    required this.status,
    required this.frequency,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    this.weight,
    this.imageUrl,
    required this.routeName,
  });
  
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'].toString(),
      userId: json['user_id'], // Correspondance avec l'API en snake_case
      basketId: json['basket_id'],
      basketName: json['basket_name'],
      deliveryPointId: json['delivery_point_id'],
      deliveryPointName: json['delivery_point_name'],
      // Convertir le statut depuis l'API (active, suspended, cancelled) à l'affichage
      status: _mapStatus(json['status']),
      frequency: json['frequency'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      price: double.parse(json['price'].toString()),
      weight: json['weight'],
      imageUrl: json['image_url'],
      routeName: json['route_name'],
    );
  }
  
  // Méthode pour mapper les statuts de l'API aux valeurs d'affichage
  static String _mapStatus(String apiStatus) {
    switch(apiStatus) {
      case 'active':
        return 'Actif';
      case 'suspended':
        return 'Suspendu';
      case 'cancelled':
        return 'Terminé';
      default:
        return 'Inconnu';
    }
  }
  
  // Méthode pour mapper les statuts d'affichage aux valeurs de l'API
  static String mapStatusToApi(String displayStatus) {
    switch(displayStatus) {
      case 'Actif':
        return 'active';
      case 'Suspendu':
        return 'suspended';
      case 'Terminé':
        return 'cancelled';
      default:
        return 'active';
    }
  }
  
  // Déterminer le type de panier en fonction du nom
  String get basketType {
    final name = basketName.toLowerCase();
    if (name.contains('petit')) return 'petit';
    if (name.contains('moyen')) return 'moyen';
    if (name.contains('grand')) return 'grand';
    return 'moyen'; // par défaut
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // Correspondance avec l'API en snake_case
      'basket_id': basketId,
      'basket_name': basketName,
      'delivery_point_id': deliveryPointId,
      'delivery_point_name': deliveryPointName,
      'status': Subscription.mapStatusToApi(status),
      'frequency': frequency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'price': price,
      'weight': weight,
      'image_url': imageUrl,
      'route_name': routeName,
    };
  }
}