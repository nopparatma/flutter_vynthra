import 'package:flutter/cupertino.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/services/api_client.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final ApiClient api;

  AppController({ApiClient? api}) : api = api ?? ApiClient();

  final RxBool isConnected = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PositionModel> positions = <PositionModel>[].obs;
  final RxList<CardModel> cards = <CardModel>[].obs;
  final RxList<CardModel> filteredCards = <CardModel>[].obs;

  @override
  void onClose() {
    api.close();
    super.onClose();
  }

  Future<bool> initializeApp() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([loadPositions(), loadCards()]);
      isConnected.value = true;

      await Future.delayed(Duration(milliseconds: 3000));

      return true;
    } catch (e) {
      isConnected.value = false;
      errorMessage.value = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      debugPrint(errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPositions() async {
    final results = await api.getList('/v1/positions');
    positions.value = results.map((data) => PositionModel.fromMap(data)).toList();
    debugPrint('loadPositions: SUCCESS');
  }

  Future<void> loadCards() async {
    final results = await api.getList('/v1/cards');
    cards.value = results.map((data) => CardModel.fromMap(data)).toList();
    resetFilteredCards();
    debugPrint('loadCards: SUCCESS');
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
