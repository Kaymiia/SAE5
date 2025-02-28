import 'package:flutter/material.dart';
import 'package:jardin_de_cocagne/models/basket.dart';
import 'package:jardin_de_cocagne/repositories/basket_repository.dart';
import 'package:jardin_de_cocagne/screens/subscription/subscription_screen.dart';
import 'package:intl/intl.dart';

class BasketDetailScreen extends StatefulWidget {
  final String basketId;
  final Basket? basket;

  const BasketDetailScreen({
    super.key, 
    required this.basketId,
    this.basket,
  });

  @override
  _BasketDetailScreenState createState() => _BasketDetailScreenState();
}

class _BasketDetailScreenState extends State<BasketDetailScreen> {
  late Future<Basket?> _basketFuture;
  final BasketRepository _repository = BasketRepository();
  
  // Variables pour la popup d'abonnement
  final List<String> _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
  String _jourSelectionne = 'Lundi';
  bool _enChargement = false;

  @override
  void initState() {
    super.initState();
    _basketFuture = widget.basket != null 
        ? Future.value(widget.basket) 
        : _fetchBasketDetails();
  }

  Future<Basket?> _fetchBasketDetails() async {
    try {
      final basket = await _repository.getBasketById(widget.basketId);
      return basket;
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
      return null;
    }
  }

  void _showSubscriptionDialog(Basket basket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S\'abonner au panier ${basket.name}',
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
                          value: _jourSelectionne,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: BorderRadius.circular(8),
                          items: _jours.map((String jour) {
                            return DropdownMenuItem<String>(
                              value: jour,
                              child: Text(jour),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _jourSelectionne = newValue!;
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
                          'Prix: ${basket.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fréquence: Hebdomadaire',
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
                            onPressed: _enChargement ? null : () => _souscrire(basket),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: const Color(0xFF1C3829),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _enChargement
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
            );
          }
        );
      },
    );
  }

  Future<void> _souscrire(Basket basket) async {
    setState(() {
      _enChargement = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          "Détail du Panier",
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Basket?>(
        future: _basketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Erreur lors du chargement du panier.'));
          }

          final basket = snapshot.data!;
          return _buildBasketContent(basket);
        },
      ),
    );
  }

  Widget _buildBasketContent(Basket basket) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du panier
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildBasketImage(basket.imageUrl),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        basket.name,
                        style: const TextStyle(
                          fontFamily: 'LilitaOne',
                          fontSize: 32,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C3829),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${basket.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Détails du panier
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de poids
                _buildTag(Icons.scale, basket.weight),

                const SizedBox(height: 24),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 22,
                    color: Color(0xFF1C3829),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  basket.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                // Contenu du panier
                const Text(
                  'Contenu du panier',
                  style: TextStyle(
                    fontFamily: 'LilitaOne',
                    fontSize: 22,
                    color: Color(0xFF1C3829),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProductList(basket),

                const SizedBox(height: 32),

                // Bouton d'abonnement
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showSubscriptionDialog(basket),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C3829),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'S\'abonner',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/default_basket.jpg',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/default_basket.jpg',
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.green[800]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(Basket basket) {
    if (basket.products.isEmpty) {
      return const Text("Aucun produit dans ce panier.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: basket.products.length,
      itemBuilder: (context, index) {
        final product = basket.products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${product.productName} (${product.quantity} ${product.unit})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}