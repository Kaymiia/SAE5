// lib/repositories/basket_repository.dart
import 'package:jardin_de_cocagne/models/basket.dart';
import 'package:jardin_de_cocagne/services/api_service.dart';
import 'package:jardin_de_cocagne/services/api_config.dart';


class BasketRepository {
  final ApiService _apiService = ApiConfig.apiService;
  
  Future<List<Basket>> getAllBaskets() async {
    final data = await _apiService.get('baskets/');
    
    if (data is List) {
      return data.map((basketData) => Basket.fromJson(basketData)).toList();
    } else {
      return [];
    }
  }
  
  Future<Basket> getBasketById(String id) async {
    final data = await _apiService.get('baskets/$id');
    
    return Basket.fromJson(data);
  }
  
  // Vous pouvez ajouter d'autres méthodes pour gérer les commandes, les abonnements, etc.
  Future<void> subscribeToBasket(String basketId, Map<String, dynamic> subscriptionData) async {
    await _apiService.post('subscriptions', {
      'basketId': basketId,
      ...subscriptionData
    });
  }
}