// lib/repositories/delivery_point_repository.dart
import 'package:jardin_de_cocagne/models/delivery_point.dart';
import 'package:jardin_de_cocagne/services/api_config.dart';
import 'package:flutter/foundation.dart';

class DeliveryPointRepository {
  final _apiService = ApiConfig.apiService;
  
  Future<List<DeliveryPoint>> getDeliveryPointsByDay(String day) async {
    try {
      debugPrint('Tentative de récupération des points pour le jour: $day');
      
      final data = await _apiService.get('delivery-points/day/$day');
      
      debugPrint('Données reçues: $data');
      
      if (data is List) {
        final points = data.map((item) => DeliveryPoint.fromJson(item)).toList();
        
        debugPrint('Nombre de points récupérés: ${points.length}');
        
        return points;
      } else {
        debugPrint('Aucun point trouvé');
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des points de livraison: $e');
      throw Exception('Échec du chargement des points de livraison pour $day');
    }
  }
  
  Future<List<String>> getAvailableDeliveryDays() async {
    try {
      debugPrint('Tentative de récupération des jours de livraison');
      
      final data = await _apiService.get('delivery-points/days');
      
      debugPrint('Jours reçus: $data');
      
      if (data is List) {
        final days = List<String>.from(data);
        
        debugPrint('Jours disponibles: $days');
        
        return days.isNotEmpty ? days : ['Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
      } else {
        debugPrint('Aucun jour trouvé, utilisation des jours par défaut');
        return ['Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des jours de livraison: $e');
      return ['Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    }
  }

  Future<DeliveryPoint> updateDeliveryPointStatus(int id, String status) async {
    try {
      final data = await _apiService.patch('delivery-points/$id/status', {
        'status': status
      });
      
      return DeliveryPoint.fromJson(data);
    } catch (e) {
      debugPrint('Erreur mise à jour statut: $e');
      throw Exception('Impossible de mettre à jour le statut');
    }
  }

  // Method to reset statuses before delivery day
  Future<void> resetDeliveryPointStatuses(String dayOfWeek) async {
    try {
      await _apiService.post('delivery-points/reset-status', {
        'day_of_week': dayOfWeek
      });
    } catch (e) {
      debugPrint('Erreur réinitialisation statuts: $e');
      throw Exception('Impossible de réinitialiser les statuts');
    }
  }
}