import 'package:flutter/material.dart';
import 'package:flutter_vynthra/utils/argument_util.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'gemini_prediction_controller.dart';

class GeminiPredictionPage extends StatefulWidget {
  const GeminiPredictionPage({super.key});

  @override
  State<GeminiPredictionPage> createState() => _GeminiPredictionPageState();
}

class _GeminiPredictionPageState extends State<GeminiPredictionPage> {
  final ScrollController scrollController = ScrollController();
  late String positionId;
  late String cardId;
  late GeminiPredictionController geminiPredictionController;

  @override
  void initState() {
    positionId = ArgumentUtil.getArgument<String>('positionId', defaultValue: '');
    cardId = ArgumentUtil.getArgument<String>('cardId', defaultValue: '');

    geminiPredictionController = Get.put(
      GeminiPredictionController(
        positionName: positionId,
        cardName: cardId,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    Get.delete<GeminiPredictionController>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'สรุปคำทำนาย',
      isShowBackAppBar: true,
      isShowMenu: false,
      scrollController: scrollController,
      body: ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () {
                if (geminiPredictionController.isLoading.value) {
                  return Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Colors.deepPurpleAccent,
                      size: 25,
                    ),
                  );
                }

                if (geminiPredictionController.errorMessage.value.isNotEmpty) {
                  return _buildErrorView(geminiPredictionController);
                }

                return _buildPredictionContent(geminiPredictionController);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPredictionContent(GeminiPredictionController controller) {
    return HtmlWidget(
      controller.predictionHtml.value.isNotEmpty ? controller.predictionHtml.value : 'ไม่พบข้อมูลคำทำนาย',
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildErrorView(GeminiPredictionController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          controller.errorMessage.value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: controller.fetchPredictionData,
          child: const Text('ลองใหม่อีกครั้ง'),
        ),
      ],
    );
  }
}
