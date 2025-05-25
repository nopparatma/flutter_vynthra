import 'package:flutter/material.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/models/position_model.dart';
import 'package:vynthra/modules/gemini_prediction/constants.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/rainbow_border_button.dart';
import 'package:get/get.dart';

class CardStandardPage extends StatefulWidget {
  const CardStandardPage({super.key});

  @override
  State<CardStandardPage> createState() => _CardStandardPageState();
}

class _CardStandardPageState extends State<CardStandardPage> {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();
  final Map<String, CardModel> selectedCards = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onPressedGeminiAI(PositionModel position) {
    Get.toNamed(
      RoutePath.geminiPrediction,
      arguments: {
        'cardItem': selectedCards[position.id],
        'positionItem': position,
        'promptType': PromptType.standard,
      },
    );
  }

  Future<void> onTapPosition(PositionModel currentPosition) async {
    CardModel? cardItemSelected = await Get.toNamed(
      RoutePath.viewAllCardsPage,
      arguments: {"isFromSelectCardOnly": true},
    ) as CardModel?;

    if (!mounted || cardItemSelected == null) return;

    bool isDuplicate = selectedCards.values.any((card) => card.id == cardItemSelected.id);

    if (isDuplicate) {
      Get.snackbar(
        'กรุณาเลือกไพ่อื่น',
        'ไพ่ "${cardItemSelected.name.th}" ถูกเลือกไปแล้ว',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      selectedCards[currentPosition.id] = cardItemSelected;
    });
  }

  void randomCard() {
    setState(() {
      var cardShuffles = (List.from(appController.cards)..shuffle()).take(appController.positions.length).toList();

      for (int i = 0; i < cardShuffles.length; i++) {
        PositionModel itemPosition = appController.positions[i];
        CardModel itemCard = cardShuffles[i];
        selectedCards[itemPosition.id] = itemCard;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: 'ไพ่ 12 ตำแหน่ง',
      scrollController: scrollController,
      isShowBackAppBar: true,
      action: TextButton.icon(
        onPressed: randomCard,
        icon: const Icon(Icons.casino_outlined),
        label: Text(
          'สุ่มไพ่',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
        ),
      ),
      body: Obx(
        () => GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: appController.positions.length,
          itemBuilder: (context, index) => _buildPositionItem(context, index),
        ),
      ),
    );
  }

  Widget _buildPositionItem(BuildContext context, int index) {
    PositionModel position = appController.positions[index];
    bool hasSelectedCard = selectedCards.containsKey(position.id);

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasSelectedCard)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedCards[position.id]?.name.th ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  RainbowBorderButton(
                    title: 'Gemini AI',
                    icon: Icons.auto_awesome_outlined,
                    onPressed: () => onPressedGeminiAI(position),
                  ),
                ],
              )
            else
              const Center(
                child: Icon(
                  Icons.add_rounded,
                ),
              ),
            if (hasSelectedCard)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCards.remove(position.id);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "${position.seq}. ${position.name.th}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => hasSelectedCard ? null : onTapPosition(position),
    );
  }
}
