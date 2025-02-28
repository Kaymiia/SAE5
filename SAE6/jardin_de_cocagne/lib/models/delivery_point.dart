// lib/models/delivery_point.dart
import 'package:flutter/material.dart';

class DeliveryPoint {
  final int id;
  final int routeId;
  final String name;
  final String address;
  final String? city;
  final double latitude;
  final double longitude;
  final int sequenceOrder;
  final String? estimatedArrivalTime;
  final String frequency;
  final String routeName;
  final String deliveryStatus; // New field
  
  DeliveryPoint({
    required this.id,
    required this.routeId,
    required this.name,
    required this.address,
    this.city,
    required this.latitude,
    required this.longitude,
    required this.sequenceOrder,
    this.estimatedArrivalTime,
    required this.frequency,
    required this.routeName,
    this.deliveryStatus = 'non livré',
  });
  
  factory DeliveryPoint.fromJson(Map<String, dynamic> json) {
    return DeliveryPoint(
      id: json['id'],
      routeId: json['route_id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      sequenceOrder: json['sequence_order'],
      estimatedArrivalTime: json['estimated_arrival_time'],
      frequency: json['day_of_week'],
      routeName: json['route_name'],
      deliveryStatus: json['delivery_status'] ?? 'non livré',
    );
  }

  // Méthode pour obtenir la couleur du statut
  Color getStatusColor() {
    switch (deliveryStatus) {
      case 'non livré':
        return Colors.red.withOpacity(0.7);
      case 'en cours':
        return Colors.orange.withOpacity(0.7);
      case 'prêt':
        return Colors.green.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }
}