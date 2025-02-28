// lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:jardin_de_cocagne/screens/map/map_screen.dart';
import 'package:jardin_de_cocagne/screens/home/home_screen.dart';
import 'package:jardin_de_cocagne/models/basket.dart';
import 'package:jardin_de_cocagne/repositories/basket_repository.dart';
import 'package:jardin_de_cocagne/screens/subscription/subscription_screen.dart';
import 'basket_detail_screen.dart';

// Import the subscription dialog
import 'subscription_dialog.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final BasketRepository _basketRepository = BasketRepository();
  List<Basket> _baskets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBaskets();
  }

  Future<void> _loadBaskets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final baskets = await _basketRepository.getAllBaskets();
      setState(() {
        _baskets = baskets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des paniers: $e';
      });
    }
  }

  void _showSubscriptionDialog(Basket basket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SubscriptionDialog(basket: basket);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          'NOS PANIERS',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Color.fromARGB(255, 255, 255, 240),
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 240),
        child: _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBaskets,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            : _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1C3829),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBaskets,
                    color: Colors.green[800],
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: _baskets.length,
                      itemBuilder: (context, index) {
                        final basket = _baskets[index];
                        return BasketCard(
                          basket: basket,
                          onDetailsPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BasketDetailScreen(
                                  basketId: basket.id,
                                  basket: basket, // Passe l'objet basket directement
                                ),
                              ),
                            );
                          },
                          onAddPressed: () {
                            _showSubscriptionDialog(basket);
                          },
                        );
                      },
                    ),
                  ),
      ),
      // Bottom navigation bar code remains the same
      bottomNavigationBar: SizedBox(
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
                currentIndex: 1,
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
                  if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeliveryMapScreen()),
                    );
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
                        onPressed: () {},
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
      ),
    );
  }
}

// BasketCard component remains the same
class BasketCard extends StatelessWidget {
  final Basket basket;
  final VoidCallback onDetailsPressed;
  final VoidCallback onAddPressed;

  const BasketCard({
    super.key, 
    required this.basket,
    required this.onDetailsPressed,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Extraire les noms des produits pour l'affichage
    final productNames = basket.products.map((p) => p.productName).toList();
    
    return Card(
      // The rest of the BasketCard implementation remains the same
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du panier
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                  tag: 'basketImage${basket.id}',
                  child: _buildBasketImage(basket.imageUrl),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C3829),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${basket.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Contenu du panier
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  basket.name,
                  style: const TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 22,
                    color: Color(0xFF1C3829),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.scale, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      basket.weight,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  basket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Contenu du panier:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: productNames.map((product) => 
                    Chip(
                      backgroundColor: Colors.green[50],
                      side: BorderSide(color: Colors.green[200]!),
                      label: Text(
                        product ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                      padding: const EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDetailsPressed,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1C3829), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Détails',
                          style: TextStyle(
                            color: Color(0xFF1C3829),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAddPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'S\'abonner',
                          style: TextStyle(
                            color: Colors.white,
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
  
  Widget _buildBasketImage(String imageUrl) {
    // Détermine si l'image est une URL ou un chemin d'asset
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    }
  }
}