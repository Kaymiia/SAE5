import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late PostgreSQLConnection _connection;
  bool _isConnected = false;

  // Singleton pattern
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> connect() async {
    if (_isConnected) return;
    
    _connection = PostgreSQLConnection(
      dotenv.env['DB_HOST'] ?? "localhost",
      int.parse(dotenv.env['DB_PORT'] ?? "5432"),
      dotenv.env['DB_NAME'] ?? "jardin_de_cocagne",
      username: dotenv.env['DB_USER'] ?? "postgres",
      password: dotenv.env['DB_PASSWORD'] ?? "password",
    );
    
    try {
      await _connection.open();
      _isConnected = true;
      print("Connexion à la base de données réussie");
    } catch (e) {
      print("Erreur de connexion à la base de données: $e");
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
      print("Connexion à la base de données fermée");
    }
  }

  Future<List<Map<String, dynamic>>> query(String sql, [Map<String, dynamic>? params]) async {
    if (!_isConnected) {
      await connect();
    }
    
    try {
      final results = await _connection.mappedResultsQuery(
        sql,
        substitutionValues: params,
      );
      
      // Conversion du format spécifique de postgres/postgres en liste simple de maps
      List<Map<String, dynamic>> resultList = [];
      for (final row in results) {
        Map<String, dynamic> flatRow = {};
        row.forEach((tableName, data) {
          flatRow.addAll(data);
        });
        resultList.add(flatRow);
      }
      
      return resultList;
    } catch (e) {
      print("Erreur lors de l'exécution de la requête: $e");
      rethrow;
    }
  }
}