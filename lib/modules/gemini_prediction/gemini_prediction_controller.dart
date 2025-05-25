import 'package:flutter/cupertino.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/models/prompt_model.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  String extractHtmlContent(String rawResponse) {
    // Check for the specific pattern: ```html <html>...</html>```
    final RegExp markdownHtmlRegex = RegExp(r'```html\s*(<html>[\s\S]*?</html>)\s*```');
    final Match? markdownMatch = markdownHtmlRegex.firstMatch(rawResponse);

    if (markdownMatch != null && markdownMatch.groupCount >= 1) {
      return markdownMatch.group(1) ?? "";
    }

    // If the exact pattern doesn't match, try a more general approach
    // Extract any content between ```html and ```
    final RegExp htmlBlockRegex = RegExp(r'```html\s*([\s\S]*?)\s*```');
    final Match? htmlBlockMatch = htmlBlockRegex.firstMatch(rawResponse);

    if (htmlBlockMatch != null && htmlBlockMatch.groupCount >= 1) {
      return htmlBlockMatch.group(1) ?? "";
    }

    // If nothing matches, check if the response itself is HTML
    if (rawResponse.contains("<html>") && rawResponse.contains("</html>")) {
      final RegExp directHtmlRegex = RegExp(r'(<html>[\s\S]*?</html>)');
      final Match? directMatch = directHtmlRegex.firstMatch(rawResponse);

      if (directMatch != null && directMatch.groupCount >= 1) {
        return directMatch.group(1) ?? "";
      }
    }

    // If nothing works, just return the original response
    return rawResponse;
  }

  String getDynamicPrompt() {
    // Find the prompt model based on prompt type
    PromptModel promptItem = appController.prompts.firstWhere(
      (e) => e.promptType.toString().toUpperCase() == promptType?.toTypeString().toUpperCase(),
    );

    // Define a map for common replacements
    final Map<String, String> replacements = {};
    final promptTypeUpper = promptItem.promptType.toUpperCase();

    // Add standard replacements based on prompt type
    if (promptTypeUpper == PromptType.standard.toTypeString().toUpperCase()) {
      replacements.addAll({
        'CARD_NAME': cardItem?.name.th ?? '',
        'POSITION_NAME': positionItem?.name.th ?? '',
        'CARD_INFO': 'รายละเอียด = ${cardItem?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cardItem?.getPredictionText(lang: 'th')}',
        'POSITION_INFO': 'รายละเอียด = ${positionItem?.getDescriptionText(lang: 'th')}',
        'HTML_SAMPLE': promptItem.responseSample,
      });
    } else if (promptTypeUpper == PromptType.question.toTypeString().toUpperCase()) {
      replacements.addAll({
        'CARD_NAME_1': cards?[0]?.name.th ?? '',
        'CARD_NAME_2': cards?[1]?.name.th ?? '',
        'CARD_NAME_3': cards?[2]?.name.th ?? '',
        'QUESTION': question ?? '',
        'CARD_INFO_1': 'รายละเอียด = ${cards?[0]?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cards?[0]?.getPredictionText(lang: 'th')}',
        'CARD_INFO_2': 'รายละเอียด = ${cards?[1]?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cards?[1]?.getPredictionText(lang: 'th')}',
        'CARD_INFO_3': 'รายละเอียด = ${cards?[2]?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cards?[2]?.getPredictionText(lang: 'th')}',
        'HTML_SAMPLE': promptItem.responseSample,
      });
    } else if (promptTypeUpper == PromptType.fortune.toTypeString().toUpperCase()) {
      replacements.addAll({
        'CARD_NAME': cardItem?.name.th ?? '',
        'QUESTION': question ?? '',
        'CARD_INFO': 'รายละเอียด = ${cardItem?.getDescriptionText(lang: 'th')}, การพยากรณ์และคำทำนายโดยละเอียด = ${cardItem?.getPredictionText(lang: 'th')}',
        'HTML_SAMPLE': promptItem.responseSample,
      });
    } else {
      return '';
    }

    // Apply all replacements to the prompt
    String result = promptItem.prompt;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  Future<String> _generateByAI() async {
    final String prompt = getDynamicPrompt();
    debugPrint('Prompt: $prompt');

    final response = await _generateAIContent(prompt);
    final String extractedHtml = extractHtmlContent(response);

    if (extractedHtml.isEmpty) {
      throw 'ไม่พบข้อมูล HTML ที่ถูกต้องจาก AI';
    }

    return extractedHtml;
  }

  Future<String> _generateAIContent(String prompt) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: 'AIzaSyDz5PEkkiO6MM_j1o5QMd2K5JP8Qn5swRA',
    );

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text == null) {
      throw Exception('ไม่มีข้อมูลคำทำนายจาก AI');
    }

    return response.text!;
  }
}
