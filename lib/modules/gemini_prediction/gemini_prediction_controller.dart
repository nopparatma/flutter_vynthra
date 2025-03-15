import 'package:flutter/cupertino.dart';
import 'package:flutter_vynthra/models/card_model.dart';
import 'package:flutter_vynthra/models/position_model.dart';
import 'package:flutter_vynthra/modules/gemini_prediction/prompt_ai.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'constants.dart';

class GeminiPredictionController extends GetxController {
  var isLoading = true.obs;
  var predictionHtml = ''.obs;
  var errorMessage = ''.obs;

  final PositionModel? positionItem;
  final CardModel? cardItem;

  GeminiPredictionController({
    required this.positionItem,
    required this.cardItem,
  });

  @override
  void onInit() {
    fetchPredictionData();
    super.onInit();
  }

  Future<void> fetchPredictionData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      const String apiKey = 'AIzaSyDz5PEkkiO6MM_j1o5QMd2K5JP8Qn5swRA';

      final model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey,
      );

      final String prompt = PromptAi(
        cardItem: cardItem,
        positionItem: positionItem,
        htmlExample: htmlDataFromAIExample,
      ).generatePrompt();
      debugPrint('Prompt: $prompt');

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        String extractedHtml = extractHtmlContent(response.text!);

        if (extractedHtml.isNotEmpty) {
          predictionHtml.value = extractedHtml;
        } else {
          errorMessage.value = 'ไม่พบข้อมูล HTML ที่ถูกต้องจาก AI';
        }
      } else {
        errorMessage.value = 'ไม่มีข้อมูลคำทำนายจาก AI';
      }
    } catch (e) {
      // errorMessage.value = 'เกิดข้อผิดพลาดในการเชื่อมต่อ AI กรุณาลองใหม่อีกครั้ง';
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
}
