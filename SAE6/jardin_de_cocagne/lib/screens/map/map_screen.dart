// lib/screens/map/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jardin_de_cocagne/screens/home/home_screen.dart';
import 'package:jardin_de_cocagne/screens/shop/shop_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:jardin_de_cocagne/repositories/route_repository.dart';
import 'package:jardin_de_cocagne/models/delivery_route.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final RouteRepository _routeRepository = RouteRepository();
  
  List<DeliveryRoute> _routes = [];
  List<String> _availableDays = [];
  String _selectedDay = 'Lundi';
  bool _isLoading = false;

  // Centre initial sur Montpellier
  final LatLng _initialPosition = const LatLng(43.610769, 3.876716);

  @override
  void initState() {
    super.initState();
    _loadAvailableDays();
  }

  Future<void> _loadAvailableDays() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final days = await _routeRepository.getAvailableDays();
      
      setState(() {
        _availableDays = days;
        if (days.isNotEmpty) {
          _selectedDay = days.first;
        }
      });
      
      // Charger les trajets pour le jour sélectionné
      if (_availableDays.isNotEmpty) {
        await _loadRoutesForDay(_selectedDay);
      }
    } catch (e) {
      // Gérer l'erreur (pourrait afficher un message)
      print('Erreur lors du chargement des jours: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRoutesForDay(String day) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final routes = await _routeRepository.getRoutesByDay(day);
      
      if (mounted) {
        setState(() {
          _routes = routes;
        });
      }
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors du chargement des trajets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<List<LatLng>> _getRoutePoints() {
    List<List<LatLng>> routePoints = [];
    
    for (final route in _routes) {
      List<LatLng> points = route.deliveryPoints.map((point) {
        return LatLng(point.latitude, point.longitude);
      }).toList();
      
      routePoints.add(points);
    }
    
    return routePoints;
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _getRoutePoints();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          'CARTE DES TRAJETS',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Color.fromARGB(255, 255, 255, 240),
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Sélecteur de jour
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFF5F5F5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableDays.map((day) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: _selectedDay == day,
                      selectedColor: const Color(0xFF1C3829),
                      labelStyle: TextStyle(
                        color: _selectedDay == day ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDay = day;
                          });
                          _loadRoutesForDay(day);
                        }
                      },
                    ),
                  )
                ).toList(),
              ),
            ),
          ),
          
          // Carte
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 12.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cocagne.app',
                    ),
                    
                    // Afficher tous les trajets
                    PolylineLayer(
                      polylines: [
                        for (final route in routePoints)
                          Polyline(
                            points: route,
                            color: const Color(0xFF1C3829),
                            strokeWidth: 4.0,
                          ),
                      ],
                    ),
                    
                    // Points de départ, arrivée et intermédiaires
                    MarkerLayer(
                      markers: [
                        for (final route in routePoints) ...[
                          // Point de départ (vert)
                          if (route.isNotEmpty)
                            Marker(
                              width: 80,
                              height: 80,
                              point: route.first,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 3,
                                        ),
                                      ]
                                    ),
                                    child: const Text(
                                      'Départ',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.trip_origin,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          // Point d'arrivée (rouge)
                          if (route.length > 1)
                            Marker(
                              width: 80,
                              height: 80,
                              point: route.last,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 3,
                                        ),
                                      ]
                                    ),
                                    child: const Text(
                                      'Arrivée',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          // Points intermédiaires
                          for (int i = 1; i < route.length - 1; i++)
                            Marker(
                              point: route[i],
                              child: const Icon(
                                Icons.circle,
                                color: Colors.blue,
                                size: 14,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
                
                // Indicateur de chargement
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1C3829),
                      ),
                    ),
                  ),
                  
                // Légende
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trip_origin, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text('Départ', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.blue, size: 12),
                            const SizedBox(width: 8),
                            Text('Étape', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Text('Arrivée', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        currentIndex: 3, // Onglet Trajets
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Paniers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket, color: Colors.transparent),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Trajets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendrier',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.moveAndRotate(_initialPosition, 12.0, 0);
        },
        backgroundColor: const Color(0xFF1C3829),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}