// lib/repositories/route_repository.dart
import '../models/delivery_route.dart';
import '../services/database_service.dart';

class RouteRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<List<DeliveryRoute>> getRoutesByDay(String day) async {
    final routesQuery = '''
      SELECT * FROM delivery_routes
      WHERE day_of_week = @day AND is_active = true
    ''';
    
    final routesResult = await _dbService.query(routesQuery, {'day': day});
    
    List<DeliveryRoute> routes = [];
    
    for (var routeData in routesResult) {
      // Pour chaque trajet, récupérer ses points de livraison associés
      final pointsQuery = '''
        SELECT * FROM delivery_points
        WHERE route_id = @routeId
        ORDER BY sequence_order
      ''';
      
      final pointsResult = await _dbService.query(
        pointsQuery, 
        {'routeId': routeData['id']}
      );
      
      List<DeliveryPoint> points = pointsResult
          .map((point) => DeliveryPoint.fromMap(point))
          .toList();
          
      routes.add(DeliveryRoute.fromMap(routeData, points));
    }
    
    return routes;
  }

  Future<List<String>> getAvailableDays() async {
    final daysQuery = '''
      SELECT DISTINCT day_of_week FROM delivery_routes
      WHERE is_active = true
      ORDER BY 
        CASE 
          WHEN day_of_week = 'Lundi' THEN 1
          WHEN day_of_week = 'Mardi' THEN 2  
          WHEN day_of_week = 'Mercredi' THEN 3
          WHEN day_of_week = 'Jeudi' THEN 4
          WHEN day_of_week = 'Vendredi' THEN 5
          WHEN day_of_week = 'Samedi' THEN 6
          WHEN day_of_week = 'Dimanche' THEN 7
        END
    ''';
    
    final daysResult = await _dbService.query(daysQuery);
    
    return daysResult
        .map((day) => day['day_of_week'] as String)
        .toList();
  }
}