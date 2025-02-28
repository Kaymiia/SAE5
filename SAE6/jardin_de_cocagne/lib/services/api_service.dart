import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint('GET $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Flutter-App'
      },
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('POST $uri');
    debugPrint('Body: $encodedData');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Flutter-App'
      },
      body: encodedData,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('PUT $uri');
    debugPrint('Body: $encodedData');
    
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Flutter-App'
      },
      body: encodedData,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('PATCH $uri');
    debugPrint('Body: $encodedData');
    
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Flutter-App'
      },
      body: encodedData,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint('DELETE $uri');
    
    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Flutter-App'
      },
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;
    
    debugPrint('Response status: $statusCode');
    if (responseBody.isNotEmpty) {
      debugPrint('Response body: $responseBody');
    }
    
    if (statusCode >= 200 && statusCode < 300) {
      if (responseBody.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(responseBody);
      } catch (e) {
        debugPrint('Erreur de décodage JSON: $e');
        throw Exception('Réponse API invalide');
      }
    } else {
      String errorMessage = 'Erreur API: $statusCode';
      
      // Essayer d'extraire un message d'erreur plus détaillé si disponible
      if (responseBody.isNotEmpty) {
        try {
          final errorJson = jsonDecode(responseBody);
          errorMessage = errorJson['message'] ?? errorMessage;
        } catch (_) {
          // Si pas de JSON valide, utiliser le corps comme message d'erreur
          if (responseBody.length < 100) {
            errorMessage = '$errorMessage - $responseBody';
          }
        }
      }
      
      throw Exception(errorMessage);
    }
  }
}

class AuthenticatedApiService extends ApiService {
  String? _token;
  
  AuthenticatedApiService({required super.baseUrl});
  
  Future<void> login(String username, String password) async {
    final response = await post('auth/login', {
      'username': username,
      'password': password
    });
    
    _token = response['token'];
  }
  
  @override
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _getAuthHeaders(),
    );
    return _handleResponse(response);
  }
  
  @override
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('POST $uri (avec auth)');
    debugPrint('Body: $encodedData');
    
    final response = await http.post(
      uri,
      headers: _getAuthHeaders(),
      body: encodedData,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('PUT $uri (avec auth)');
    debugPrint('Body: $encodedData');
    
    final response = await http.put(
      uri,
      headers: _getAuthHeaders(),
      body: encodedData,
    );
    return _handleResponse(response);
  }
  
  @override
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final encodedData = jsonEncode(data);
    
    debugPrint('PATCH $uri (avec auth)');
    debugPrint('Body: $encodedData');
    
    final response = await http.patch(
      uri,
      headers: _getAuthHeaders(),
      body: encodedData,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _getAuthHeaders(),
    );
    return _handleResponse(response);
  }
  
  Map<String, String> _getAuthHeaders() {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json',
        'User-Agent': 'Flutter-App'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
}