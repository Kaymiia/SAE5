// lib/repositories/route_repository.dart
import 'package:jardin_de_cocagne/models/delivery_route.dart';
import 'package:jardin_de_cocagne/services/api_service.dart';
import 'package:jardin_de_cocagne/services/api_config.dart';


class RouteRepository {
    final ApiService _apiService = ApiConfig.apiService;

  Future<List<String>> getAvailableDays() async {
    final data = await _apiService.get('delivery-days');
    
    if (data is List) {
      return data.map((day) => day.toString()).toList();
    } else {
      return [];
    }
  }
  
  Future<List<DeliveryRoute>> getRoutesByDay(String day) async {
    final data = await _apiService.get('routes?day=$day');
    
    if (data is List) {
      return data.map((routeData) => DeliveryRoute.fromJson(routeData)).toList();
    } else {
      return [];
    }
  }
}