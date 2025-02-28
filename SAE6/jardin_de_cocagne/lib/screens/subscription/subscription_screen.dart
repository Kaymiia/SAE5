// lib/screens/subscription/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:jardin_de_cocagne/models/subscription.dart';
import 'package:jardin_de_cocagne/repositories/subscription_repository.dart';
import 'package:jardin_de_cocagne/screens/shop/shop_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();
  bool _isLoading = true;
  List<Subscription> _subscriptions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final subscriptions = await _subscriptionRepository.getUserSubscriptions();
      
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des abonnements';
      });
    }
  }

  Future<void> _updateSubscriptionStatus(String id, String currentStatus) async {
    try {
      String newStatus;
      
      // Calculer le nouveau statut
      if (currentStatus == 'Actif') {
        newStatus = 'Suspendu';
      } else if (currentStatus == 'Suspendu') {
        newStatus = 'Actif';
      } else {
        return; // Ne rien faire si c'est annulé
      }
      
      // Mettre à jour en base
      await _subscriptionRepository.updateSubscriptionStatus(id, newStatus);
      
      // Rafraîchir les données
      _loadSubscriptions();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          'MES ABONNEMENTS',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Color.fromARGB(255, 255, 255, 240),
            fontSize: 24,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSubscriptions,
        color: Colors.green[800],
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 240),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C3829)))
              : _errorMessage != null
                  ? _buildErrorView()
                  : _subscriptions.isEmpty
                      ? _buildEmptyView()
                      : _buildSubscriptionsList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFF1C3829)),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Une erreur est survenue',
            style: const TextStyle(color: Color(0xFF1C3829)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSubscriptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C3829),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Vous n\'avez pas encore d\'abonnements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C3829),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visitez notre boutique pour découvrir nos paniers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigation vers la boutique
            },
            icon: const Icon(Icons.shopping_basket, color: Colors.white),
            label: const Text(
              'Voir les paniers',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        return _buildSubscriptionCard(subscription);
      },
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: subscription.imageUrl != null && subscription.imageUrl!.isNotEmpty
                    ? NetworkImage(subscription.imageUrl!)
                    : AssetImage(_getBasketImage(subscription.basketType)) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.basketName,
                  style: const TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 20,
                    color: Color(0xFF1C3829),
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today, 'Fréquence: ${subscription.frequency}'),
                _buildInfoRow(Icons.location_on, subscription.deliveryPointName),
                if (subscription.weight != null && subscription.weight!.isNotEmpty)
                  _buildInfoRow(Icons.scale, 'Poids: ${subscription.weight}'),
                _buildInfoRow(Icons.euro, '${subscription.price.toStringAsFixed(2)}€'),
                _buildStatusBadge(subscription.status),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: subscription.status != 'Terminé'
                            ? () => _updateSubscriptionStatus(subscription.id, subscription.status)
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: subscription.status == 'Actif' 
                                ? Colors.orange 
                                : subscription.status == 'Suspendu'
                                    ? Colors.green
                                    : Colors.grey,
                            width: 2
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          subscription.status == 'Actif' ? 'Suspendre' : 'Reprendre',
                          style: TextStyle(
                            color: subscription.status == 'Actif' 
                                ? Colors.orange 
                                : subscription.status == 'Suspendu'
                                    ? Colors.green
                                    : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigation vers les détails de l'abonnement
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Détails',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case 'Actif':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'Suspendu':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'Terminé':
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        break;
      default:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getBasketImage(String type) {
    switch (type.toLowerCase()) {
      case 'petit':
        return 'assets/images/Le_Petit.png';
      case 'moyen':
        return 'assets/images/Le_Moyen.png';
      case 'grand':
        return 'assets/images/Le_Grand.png';
      default:
        return 'assets/images/Le_Moyen.png';
    }
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 75,
            left: 0,
            right: 0,
            child: Container(
              clipBehavior: Clip.none,
              height: 90,
              color: const Color.fromARGB(0, 0, 0, 0),
              child: Image.asset(
                'assets/images/grass.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green[800],
              unselectedItemColor: Colors.grey[600],
              currentIndex: 1, // Index pour l'onglet Abonnements
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
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 85,
                width: 85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 68,
                    width: 68,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShopScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.shopping_basket,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}