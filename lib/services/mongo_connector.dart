import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoConnector {
  // Singleton instance
  static final MongoConnector _instance = MongoConnector._internal();

  // Factory constructor
  factory MongoConnector() => _instance;

  // Internal constructor
  MongoConnector._internal();

  // MongoDB connection instance
  Db? _db;

  // Connection status
  bool get isConnected => _db != null && _db!.isConnected;

  // Configuration
  String _host = "localhost";
  String _dbName = "myapp";
  String _username = "";
  String _password = "";

  // Configure the connection
  void configure({
    required String host,
    required String dbName,
    String username = "",
    String password = "",
  }) {
    _host = host;
    _dbName = dbName;
    _username = username;
    _password = password;
  }

  // Connect to MongoDB
  Future<void> connect() async {
    if (isConnected) return;

    try {
      String connectionString = "mongodb+srv://$_username:$_password@$_host/$_dbName";

      _db = await Db.create(connectionString);
      await _db!.open();

      debugPrint("Connected to MongoDB at $_host/$_dbName");
    } catch (e) {
      debugPrint("Error connecting to MongoDB: $e");
      rethrow;
    }
  }

  // Disconnect from MongoDB
  Future<void> disconnect() async {
    if (!isConnected) return;

    try {
      await _db!.close();
      _db = null;
      debugPrint("Disconnected from MongoDB");
    } catch (e) {
      debugPrint("Error disconnecting from MongoDB: $e");
      rethrow;
    }
  }

  // Get a collection
  DbCollection getCollection(String collectionName) {
    if (!isConnected) {
      throw Exception("Not connected to MongoDB");
    }

    return _db!.collection(collectionName);
  }

  Future<List<Map<String, dynamic>>> find(
    String collectionName, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? fields,
  }) async {
    final collection = getCollection(collectionName);
    final selector = query ?? {};

    final cursor = collection.find(
      selector,
    );

    final List<Map<String, dynamic>> results = await cursor.toList();
    return results;
  }

  // Find one document
  Future<Map<String, dynamic>?> findOne(
    String collectionName, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? fields,
  }) async {
    final collection = getCollection(collectionName);
    final selector = query ?? {};

    final result = await collection.findOne(
      selector,
    );

    return result;
  }
}
