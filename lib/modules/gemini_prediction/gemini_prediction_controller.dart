import 'package:flutter/cupertino.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:get/get.dart';
import 'package:vynthra/utils/shared_pref_util.dart';

import 'constants.dart';

class GeminiPredictionController extends GetxController {
  var isLoading = true.obs;
  var predictionHtml = ''.obs;
  var errorMessage = ''.obs;

  final AppController appController = Get.find<AppController>();

  final PositionModel? positionItem;
  final CardModel? cardItem;
  final String? question;
  final PromptType? promptType;
  final Map<int, CardModel>? cards;

  GeminiPredictionController({
    this.positionItem,
    this.cardItem,
    this.question,
    this.cards,
    required this.promptType,
  });

  @override
  void onInit() {
    fetchPredictionData();
    super.onInit();
  }

  Future<void> fetchPredictionData({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final String cacheKey = '${cardItem?.id}_${positionItem?.id}';

      if (!isRefresh && PromptType.standard == promptType && await SharedPrefUtil.containsKey(cacheKey)) {
        predictionHtml.value = await SharedPrefUtil.read(cacheKey);
        return;
      }

      String result = await _generateByAI();
      predictionHtml.value = result;

      if (PromptType.standard == promptType) {
        await SharedPrefUtil.save(cacheKey, result);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      errorMessage.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Asks vynthra_service for a prediction. The service builds the prompt
  /// from its own card data and calls the AI model.
  Future<String> _generateByAI() async {
    final Map<String, dynamic> payload = {'type': promptType?.toTypeString()};

    switch (promptType) {
      case PromptType.standard:
        payload['cardId'] = cardItem?.id;
        payload['positionId'] = positionItem?.id;
      case PromptType.question:
        payload['cardIds'] = [cards?[0]?.id, cards?[1]?.id, cards?[2]?.id];
        payload['question'] = question ?? '';
      case PromptType.fortune:
        payload['cardId'] = cardItem?.id;
        payload['question'] = question ?? '';
      case null:
        throw 'ไม่พบประเภทคำทำนาย';
    }

    final response = await appController.api.post('/v1/predictions', payload);
    final String html = response['html'] ?? '';

    if (html.isEmpty) {
      throw 'ไม่พบข้อมูล HTML ที่ถูกต้องจาก AI';
    }

    return html;
  }
}
