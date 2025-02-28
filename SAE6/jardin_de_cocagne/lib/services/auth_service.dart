import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ID utilisateur qui existe dans la base de données
  static const int _userId = 1;
  
  // Récupérer l'ID de l'utilisateur courant
  Future<int> getCurrentUserId() async {
    return _userId;
  }
  
  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    // Pour une implémentation réelle, vérifier si un token est stocké
    return true; // Toujours connecté pour la démo
  }
  
  // Récupérer les informations de l'utilisateur
  Future<Map<String, dynamic>> getUserInfo() async {
    return {
      'id': _userId,
      'name': 'Utilisateur Démo',
      'email': 'demo@example.com',
      'photo': '',
    };
  }
  
  // Déconnexion
  Future<void> signOut() async {
    debugPrint('Déconnexion simulée');
  }
}