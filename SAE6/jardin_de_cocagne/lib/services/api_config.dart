// lib/services/api_config.dart
import 'package:jardin_de_cocagne/services/api_service.dart';

class ApiConfig {
  // URL de votre API selon l'environnement (dev, staging, prod)
  static final String baseUrl = 'https://press-publication-income-collecting.trycloudflare.com/api';
  
  // Singleton pour l'API Service
  static final ApiService _apiService = ApiService(baseUrl: baseUrl);
  
  static ApiService get apiService => _apiService;
}