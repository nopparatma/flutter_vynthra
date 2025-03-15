import 'package:flutter/material.dart';
import 'package:flutter_vynthra/utils/argument_util.dart';
import 'package:flutter_vynthra/widget/custom_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import 'gemini_loading_animation.dart';
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

  void onPressRefresh() {
    geminiPredictionController.fetchPredictionData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // Determine if the refresh action should be shown
        final bool showRefreshAction = !geminiPredictionController.isLoading.value;

        return CommonLayout(
          title: 'สรุปคำทำนาย AI',
          isShowBackAppBar: true,
          isShowMenu: false,
          action: !showRefreshAction
              ? null
              : IconButton(
                  onPressed: onPressRefresh,
                  icon: const Icon(
                    Icons.refresh,
                    size: 30,
                  ),
                ),
          scrollController: scrollController,
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (geminiPredictionController.isLoading.value) {
      return _buildLoading();
    }

    if (geminiPredictionController.errorMessage.value.isNotEmpty) {
      return _buildErrorView(geminiPredictionController);
    }

    return _buildPredictionContent(geminiPredictionController);
  }

  Widget _buildPredictionContent(GeminiPredictionController controller) {
    return ListView(
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: HtmlWidget(
            controller.predictionHtml.value.isNotEmpty ? controller.predictionHtml.value : 'ไม่พบข้อมูลคำทำนาย',
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 50),
      ],
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

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GeminiLoadingAnimation(
            imagePath: 'assets/images/gemini_logo.png',
            width: 200,
            height: 200,
            blinkDuration: const Duration(seconds: 1),
          ),
          const SizedBox(height: 32),
          const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
