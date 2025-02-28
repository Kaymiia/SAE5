import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:jardin_de_cocagne/models/delivery_point.dart';
import 'package:jardin_de_cocagne/repositories/delivery_point_repository.dart';

class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({super.key});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final MapController _mapController = MapController();
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String _currentDay = 'Mardi';
  List<DeliveryPoint> _currentPoints = [];
  String? _error;

  final List<String> _availableDays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
  final DeliveryPointRepository _repository = DeliveryPointRepository();

  @override
  void initState() {
    super.initState();
    _loadAvailableDays();
    _loadPointsForDay(_currentDay);
  }
  
  Future<void> _loadAvailableDays() async {
    try {
      final days = await _repository.getAvailableDeliveryDays();
      if (days.isNotEmpty) {
        setState(() {
          _availableDays.clear();
          _availableDays.addAll(days);
          _currentDay = days.first;
        });
        _loadPointsForDay(_currentDay);
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les jours disponibles';
      });
    }
  }

  Future<void> _loadPointsForDay(String day) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentDay = day;
    });

    try {
      final points = await _repository.getDeliveryPointsByDay(day);
      
      setState(() {
        _currentPoints = points;
        _isLoading = false;
      });
      
      _createMarkers();
      _centerMapOnPoints();
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les points de livraison';
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
  setState(() {
    _markers.clear();
    
    for (var i = 0; i < _currentPoints.length; i++) {
      final point = _currentPoints[i];
      _markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(point.latitude, point.longitude),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(point.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(point.city ?? point.address),
                      const SizedBox(height: 8),
                      Text(
                        'Statut: ${point.deliveryStatus}',
                        style: TextStyle(
                          color: point.getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: point.getStatusColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  });
}

  void _centerMapOnPoints() {
    if (_currentPoints.isEmpty) return;
    
    double minLat = _currentPoints.first.latitude;
    double maxLat = _currentPoints.first.latitude;
    double minLng = _currentPoints.first.longitude;
    double maxLng = _currentPoints.first.longitude;
    
    for (var point in _currentPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    
    _mapController.move(center, 11.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          'POINTS DE DÉPÔT',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Color.fromARGB(255, 255, 255, 240),
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(48.17436, 6.44962),
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jardindecocagne.app',
              ),
              MarkerLayer(markers: _markers.toList()),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1C3829),
              ),
            ),
          if (_error != null)
            _buildErrorWidget(),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildDaySelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPointsForDay(_currentDay),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C3829),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionnez un jour',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C3829),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableDays.map((day) {
                final isSelected = day == _currentDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => _loadPointsForDay(day),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF1C3829) : Colors.white,
                      foregroundColor: isSelected ? Colors.white : const Color(0xFF1C3829),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      side: BorderSide(
                        color: const Color(0xFF1C3829),
                        width: 1,
                      ),
                    ),
                    child: Text(day),
                  ),
                );
              }).toList(),
            ),
          ),
          if (!_isLoading && _error == null) ...[
            const SizedBox(height: 8),
            if (_currentPoints.isEmpty)
              const Text(
                'Aucun point de dépôt pour ce jour',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                '${_currentPoints.length} points de dépôt',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            if (_currentDay == 'Mardi')
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'Attention, nous ne livrons pas de fruits le mardi',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}