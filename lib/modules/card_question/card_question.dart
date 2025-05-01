import 'package:flutter/material.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/modules/gemini_prediction/constants.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/rainbow_border_button.dart';
import 'package:get/get.dart';

class CardQuestionPage extends StatefulWidget {
  const CardQuestionPage({super.key});

  @override
  State<CardQuestionPage> createState() => _CardQuestionPageState();
}

class _CardQuestionPageState extends State<CardQuestionPage> {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();
  final FocusNode textFocusNode = FocusNode();
  final TextEditingController questionController = TextEditingController();
  final Map<int, CardModel> selectedCards = {};
  final cardPositions = ['ไพ่หลัก', 'ไพ่อารมณ์', 'ไพ่สรุป'];

  @override
  void initState() {
    super.initState();

    if (appController.cards.isEmpty) {
      appController.loadCards();
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  void _clearFocus() {
    if (textFocusNode.hasFocus) {
      textFocusNode.unfocus();
    }
  }

  Future<void> onTapPosition(int position) async {
    _clearFocus();

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

    selectCard(position, cardItemSelected);
  }

  void selectCard(int position, CardModel card) {
    setState(() {
      selectedCards[position] = card;
    });
  }

  void resetSelection() {
    _clearFocus();

    setState(() {
      selectedCards.clear();
    });
  }

  void startReading() {
    _clearFocus();

    if (questionController.text.trim().isEmpty) {
      Get.snackbar(
        'กรุณากรอกคำถามก่อนทำนาย',
        'โปรดพิมพ์คำถามที่คุณต้องการคำตอบก่อนทำนาย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCards.length < 3) {
      Get.snackbar(
        'กรุณาเลือกไพ่ให้ครบ 3 ใบ',
        'โปรดเลือกไพ่ให้ครบทุกใบก่อนทำนาย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );

      return;
    }

    final Map<String, dynamic> readingData = {
      'question': questionController.text,
      'cards': selectedCards,
      'promptType': PromptType.question,
    };

    Get.toNamed(
      RoutePath.geminiPrediction,
      arguments: readingData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearFocus,
      child: CommonLayout(
        title: 'ไพ่ตอบคำถาม',
        scrollController: scrollController,
        isShowBackAppBar: true,
        body: Obx(() {
          final bool isLoading = appController.isLoading.value;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuestionInputSection(
                      questionController: questionController,
                      searchFocusNode: textFocusNode,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เลือกไพ่ 3 ใบ',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(3, (index) {
                            final position = cardPositions[index];
                            final selectedCard = selectedCards[index];

                            return SelectedCardSlot(
                              position: position,
                              selectedCard: selectedCard,
                              onSelect: () => onTapPosition(index),
                            );
                          }),
                        ),
                      ],
                    ),
                    if (selectedCards.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          onPressed: resetSelection,
                          icon: const Icon(Icons.restart_alt_outlined),
                          label: Text(
                            'ล้างไพ่',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    RainbowBorderButton(
                      title: 'ทำนาย',
                      icon: Icons.auto_awesome_outlined,
                      onPressed: () => startReading(),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}

class QuestionInputSection extends StatelessWidget {
  final TextEditingController questionController;
  final FocusNode searchFocusNode;

  const QuestionInputSection({
    super.key,
    required this.questionController,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'คำถามของคุณ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'ตัวอย่างคำถาม: "ฉันควรเปลี่ยนงานไหม?", "ความรักของฉันจะเป็นอย่างไร?"',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: questionController,
            focusNode: searchFocusNode,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'พิมพ์คำถามที่คุณต้องการคำตอบ...',
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            maxLines: 4,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}

class SelectedCardSlot extends StatelessWidget {
  final String position;
  final CardModel? selectedCard;
  final VoidCallback onSelect;

  const SelectedCardSlot({
    super.key,
    required this.position,
    required this.selectedCard,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          position,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onSelect,
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              color: selectedCard != null ? Colors.transparent : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedCard != null ? Colors.transparent : Colors.grey,
                width: 2,
              ),
            ),
            child: selectedCard != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedCard!.imageUrl.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            selectedCard!.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: Colors.amber,
                              );
                            },
                          ),
                        )
                      else
                        const Expanded(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: Colors.amber,
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
