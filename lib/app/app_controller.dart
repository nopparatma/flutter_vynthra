import 'package:flutter/cupertino.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/services/mongo_connector.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final MongoConnector _mongo = MongoConnector();

  final RxBool isConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PositionModel> positions = <PositionModel>[].obs;
  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxList<CardModel> filteredCards = <CardModel>[].obs;

  @override
  void onClose() {
    _mongo.disconnect();
    super.onClose();
  }

  Future<bool> initializeApp() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _mongo.configure(
        host: "cluster0.ridkr.mongodb.net",
        dbName: "vynthra",
        username: "username",
        password: "692345",
      );

      await _mongo.connect();
      isConnected.value = true;

      await loadPositions();
      await loadCards();

      await Future.delayed(Duration(milliseconds: 3000));

      return true;
    } catch (e) {
      errorMessage.value = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      debugPrint(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPositions() async {
    try {
      final List<Map<String, dynamic>> results = await _mongo.find('positions');
      positions.value = results.map((data) => PositionModel.fromMap(data)).toList();
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการโหลดข้อมูลผู้ใช้: $e');
    }
  }

  Future<void> loadCards() async {
    try {
      final List<Map<String, dynamic>> results = await _mongo.find('cards');
      cards.value = results.map((data) => CardModel.fromMap(data)).toList();
      resetFilteredCards();
    } catch (e) {
      debugPrint('เกิดข้อผิดพลาดในการโหลดข้อมูลผู้ใช้: $e');
    }
  }

  void resetFilteredCards() {
    filteredCards.value = cards;
  }

  void filterCards(String searchText) {
    if (searchText.isEmpty) {
      resetFilteredCards();
    } else {
      filteredCards.value = cards.where((card) {
        final thNameMatch = card.name.th.toLowerCase().contains(searchText.toLowerCase());
        final enNameMatch = card.name.en.toLowerCase().contains(searchText.toLowerCase());
        return thNameMatch || enNameMatch;
      }).toList();
    }
  }
}
