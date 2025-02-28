import 'package:flutter/material.dart';
import 'package:jardin_de_cocagne/models/basket.dart';
import 'package:jardin_de_cocagne/models/delivery_point.dart';
import 'package:jardin_de_cocagne/repositories/delivery_point_repository.dart';
import 'package:jardin_de_cocagne/repositories/subscription_repository.dart';
import 'package:jardin_de_cocagne/screens/subscription/subscription_screen.dart';

class SubscriptionDialog extends StatefulWidget {
  final Basket basket;

  const SubscriptionDialog({super.key, required this.basket});

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final List<String> _weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
  String _selectedDay = 'Lundi';
  int? _selectedDeliveryPointId;
  final SubscriptionRepository _repository = SubscriptionRepository();
  final DeliveryPointRepository _deliveryPointRepository = DeliveryPointRepository();
  bool _isLoading = false;
  bool _isLoadingPoints = true;
  List<DeliveryPoint> _deliveryPoints = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeliveryPointsForDay(_selectedDay);
  }

  Future<void> _loadDeliveryPointsForDay(String day) async {
    setState(() {
      _isLoadingPoints = true;
      _error = null;
    });

    try {
      final points = await _deliveryPointRepository.getDeliveryPointsByDay(day);
      
      setState(() {
        _deliveryPoints = points;
        _isLoadingPoints = false;
        
        // Sélectionner le premier point par défaut s'il y en a
        if (points.isNotEmpty) {
          _selectedDeliveryPointId = points.first.id;
        } else {
          _selectedDeliveryPointId = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les points de livraison';
        _isLoadingPoints = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'S\'abonner au panier ${widget.basket.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C3829),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choisissez votre jour de livraison :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    borderRadius: BorderRadius.circular(8),
                    items: _weekdays.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDay = newValue;
                        });
                        _loadDeliveryPointsForDay(newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choisissez votre point de livraison :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingPoints)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              else if (_deliveryPoints.isEmpty)
                const Center(
                  child: Text(
                    'Aucun point de livraison disponible ce jour-là',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedDeliveryPointId,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      borderRadius: BorderRadius.circular(8),
                      items: _deliveryPoints.map((DeliveryPoint point) {
                        return DropdownMenuItem<int>(
                          value: point.id,
                          child: Text('${point.name} - ${point.city ?? point.address}'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedDeliveryPointId = newValue;
                        });
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prix: ${widget.basket.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / Semaine',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedDeliveryPointId == null 
                          ? null 
                          : _subscribe,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF1C3829),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmer',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe() async {
    if (_selectedDeliveryPointId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un point de livraison'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser directement idAsInt du modèle Basket
      final basketId = widget.basket.idAsInt;
      
      if (basketId <= 0) {
        throw Exception("L'ID du panier n'est pas un nombre valide");
      }

      debugPrint('Création abonnement avec basketId=$basketId, deliveryPointId=${_selectedDeliveryPointId}');
      
      // Création d'un nouvel abonnement en utilisant la méthode mise à jour
      await _repository.createSubscription(
        basketId: basketId,
        deliveryPointId: _selectedDeliveryPointId!,
        status: 'active'
      );

      if (mounted) {
        Navigator.pop(context); // Fermer la popup
        
        // Rediriger vers la page des abonnements
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
        );

        // Montrer un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abonnement créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création de l\'abonnement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}