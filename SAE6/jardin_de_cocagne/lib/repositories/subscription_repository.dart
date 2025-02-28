// lib/repositories/subscription_repository.dart
import 'package:jardin_de_cocagne/models/subscription.dart';
import 'package:jardin_de_cocagne/services/api_config.dart';
import 'package:jardin_de_cocagne/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class SubscriptionRepository {
  final _apiService = ApiConfig.apiService;
  final _authService = AuthService();
  
  Future<List<Subscription>> getUserSubscriptions() async {
    try {
      final userId = await _authService.getCurrentUserId();
      final data = await _apiService.get('subscriptions/user/$userId');
      
      if (data is List) {
        return data.map((item) => Subscription.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des abonnements: $e');
      throw Exception('Échec du chargement des abonnements');
    }
  }
  
  Future<Subscription> getSubscriptionById(String id) async {
    final data = await _apiService.get('subscriptions/$id');
    return Subscription.fromJson(data);
  }
  
  Future<Subscription> updateSubscriptionStatus(String id, String displayStatus) async {
    final apiStatus = Subscription.mapStatusToApi(displayStatus);
    
    final data = await _apiService.patch('subscriptions/$id/status', {
      'status': apiStatus,
    });
    
    return Subscription.fromJson(data);
  }
  
  Future<bool> cancelSubscription(String id) async {
    await _apiService.delete('subscriptions/$id');
    return true;
  }
  
  Future<Subscription> createSubscription({
    required int basketId,
    required int deliveryPointId,
    String status = 'active'
  }) async {
    try {
      final userId = await _authService.getCurrentUserId();
      
      // 1. Vérifier que les paramètres sont bien des entiers
      if (basketId <= 0) {
        throw Exception('ID de panier invalide');
      }
      
      if (deliveryPointId <= 0) {
        throw Exception('ID de point de livraison invalide');
      }
      
      // 2. Test avec un appel à /test pour vérifier le format des données
      try {
        final testData = {
          'user_id': userId,
          'basket_id': basketId,
          'delivery_point_id': deliveryPointId,
          'status': status
        };
        
        debugPrint('Test données: $testData');
        await _apiService.post('subscriptions/test', testData);
      } catch (e) {
        debugPrint('Test échoué: $e');
      }
      
      // 3. Créer l'abonnement avec des entiers explicites
      final subscriptionData = {
        'user_id': userId,
        'basket_id': basketId,
        'delivery_point_id': deliveryPointId,
        'status': status
      };
      
      debugPrint('Envoi données: $subscriptionData');
      
      final data = await _apiService.post('subscriptions', subscriptionData);
      return Subscription.fromJson(data);
    } catch (e) {
      debugPrint('Erreur détaillée lors de la création: $e');
      throw Exception('Échec de la création de l\'abonnement: $e');
    }
  }
}