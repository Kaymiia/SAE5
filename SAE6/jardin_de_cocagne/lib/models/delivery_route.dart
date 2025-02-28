// lib/models/delivery_route.dart (mise à jour)
import 'package:latlong2/latlong.dart';

class DeliveryPoint {
  final double latitude;
  final double longitude;
  final String? name;
  
  DeliveryPoint({
    required this.latitude, 
    required this.longitude,
    this.name,
  });
  
  factory DeliveryPoint.fromJson(Map<String, dynamic> json) {
    return DeliveryPoint(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      name: json['name'],
    );
  }
}

class DeliveryRoute {
  final String id;
  final String day;
  final List<DeliveryPoint> deliveryPoints;
  
  DeliveryRoute({
    required this.id,
    required this.day,
    required this.deliveryPoints,
  });
  
  factory DeliveryRoute.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List)
        .map((point) => DeliveryPoint.fromJson(point))
        .toList();
    
    return DeliveryRoute(
      id: json['id'],
      day: json['day'],
      deliveryPoints: pointsList,
    );
  }
}