// lib/models/delivery_route.dart
import 'package:latlong2/latlong.dart';

class DeliveryRoute {
  final int id;
  final String name;
  final String dayOfWeek;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DeliveryPoint> deliveryPoints;

  DeliveryRoute({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryPoints,
  });

  factory DeliveryRoute.fromMap(Map<String, dynamic> map, List<DeliveryPoint> points) {
    return DeliveryRoute(
      id: map['id'],
      name: map['name'],
      dayOfWeek: map['day_of_week'],
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : DateTime.now(),
      updatedAt: map['updated_at'] != null 
        ? DateTime.parse(map['updated_at']) 
        : DateTime.now(),
      deliveryPoints: points,
    );
  }
}

class DeliveryPoint {
  final int id;
  final int routeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final DateTime? estimatedArrivalTime;

  DeliveryPoint({
    required this.id,
    required this.routeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.estimatedArrivalTime,
  });

  factory DeliveryPoint.fromMap(Map<String, dynamic> map) {
    return DeliveryPoint(
      id: map['id'],
      routeId: map['route_id'],
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] is int) 
        ? (map['latitude'] as int).toDouble() 
        : map['latitude'],
      longitude: (map['longitude'] is int) 
        ? (map['longitude'] as int).toDouble() 
        : map['longitude'],
      sequenceOrder: map['sequence_order'] ?? 0,
      estimatedArrivalTime: map['estimated_arrival_time'] != null 
        ? DateTime.parse(map['estimated_arrival_time']) 
        : null,
    );
  }
}