import 'package:flutter/material.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/modules/gemini_prediction/constants.dart';
import 'package:vynthra/utils/argument_util.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/custom_loading.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import 'widgets/gemini_loading_animation.dart';
import 'gemini_prediction_controller.dart';

class GeminiPredictionPage extends StatefulWidget {
  const GeminiPredictionPage({super.key});

  @override
  State<GeminiPredictionPage> createState() => _GeminiPredictionPageState();
}

class _GeminiPredictionPageState extends State<GeminiPredictionPage> {
  final ScrollController scrollController = ScrollController();
  late PositionModel? positionItem;
  late CardModel? cardItem;
  late PromptType? promptType;
  late String? question;
  late GeminiPredictionController geminiPredictionController;
  late Map<int, CardModel>? cards;

  @override
  void initState() {
    positionItem = ArgumentUtil.getArgument<PositionModel>('positionItem');
    cardItem = ArgumentUtil.getArgument<CardModel>('cardItem');
    promptType = ArgumentUtil.getArgument<PromptType>('promptType');
    question = ArgumentUtil.getArgument<String>('question');
    cards = ArgumentUtil.getArgument<Map<int, CardModel>>('cards');

    geminiPredictionController = Get.put(
      GeminiPredictionController(
        positionItem: positionItem,
        cardItem: cardItem,
        question: question,
        cards: cards,
        promptType: promptType,
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
    geminiPredictionController.fetchPredictionData(isRefresh: true);
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
            textStyle: Theme.of(context).textTheme.bodyLarge,
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
          child: Text(
            'ลองใหม่อีกครั้ง',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
          CustomLoadingWidget(),
        ],
      ),
    );
  }
}
