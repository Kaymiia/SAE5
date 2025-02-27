// lib/repositories/basket_repository.dart
import '../models/basket.dart';
import '../services/database_service.dart';

class BasketRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<List<Basket>> getAllBaskets() async {
    try {
      await _dbService.connect();
      
      final basketsQuery = '''
        SELECT * FROM baskets WHERE is_active = true
      ''';
      
      final basketsResult = await _dbService.query(basketsQuery);
      
      List<Basket> baskets = [];
      
      for (var basketData in basketsResult) {
        // Pour chaque panier, récupérer ses produits associés
        final productsQuery = '''
          SELECT bp.id, bp.basket_id, bp.product_id, bp.quantity, 
                 p.name, p.category, p.unit
          FROM basket_products bp
          JOIN products p ON bp.product_id = p.id
          WHERE bp.basket_id = @basketId
        ''';
        
        final productsResult = await _dbService.query(
          productsQuery, 
          {'basketId': basketData['id']}
        );
        
        List<BasketProduct> products = productsResult
            .map((product) => BasketProduct.fromMap(product))
            .toList();
            
        baskets.add(Basket.fromMap(basketData, products));
      }
      
      return baskets;
    } catch (e) {
      print('Error fetching baskets: $e');
      rethrow;
    }
  }
  
  Future<Basket?> getBasketById(int id) async {
    try {
      await _dbService.connect();
      
      final basketQuery = '''
        SELECT * FROM baskets WHERE id = @id
      ''';
      
      final basketResult = await _dbService.query(basketQuery, {'id': id});
      
      if (basketResult.isEmpty) {
        return null;
      }
      
      final productsQuery = '''
        SELECT bp.id, bp.basket_id, bp.product_id, bp.quantity, 
               p.name, p.category, p.unit
        FROM basket_products bp
        JOIN products p ON bp.product_id = p.id
        WHERE bp.basket_id = @basketId
      ''';
      
      final productsResult = await _dbService.query(
        productsQuery, 
        {'basketId': basketResult.first['id']}
      );
      
      List<BasketProduct> products = productsResult
          .map((product) => BasketProduct.fromMap(product))
          .toList();
          
      return Basket.fromMap(basketResult.first, products);
    } catch (e) {
      print('Error fetching basket by ID: $e');
      rethrow;
    }
  }
  
  // Ajouter de nouvelles méthodes pour interagir avec la base de données
  Future<bool> subscribeToBasket(int basketId, int userId) async {
    try {
      await _dbService.connect();
      
      final subscribeQuery = '''
        INSERT INTO user_subscriptions (user_id, basket_id, status, created_at, updated_at)
        VALUES (@userId, @basketId, 'active', NOW(), NOW())
        ON CONFLICT (user_id, basket_id)
        DO UPDATE SET status = 'active', updated_at = NOW()
        RETURNING id
      ''';
      
      final result = await _dbService.query(
        subscribeQuery, 
        {'userId': userId, 'basketId': basketId}
      );
      
      return result.isNotEmpty;
    } catch (e) {
      print('Error subscribing to basket: $e');
      return false;
    }
  }
}