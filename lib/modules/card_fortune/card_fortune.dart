import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/models/card_model.dart';
import 'package:vynthra/modules/gemini_prediction/constants.dart';
import 'package:vynthra/widget/card_shuffle_animation.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:vynthra/widget/rainbow_border_button.dart';
import 'package:get/get.dart';

class CardFortunePage extends StatefulWidget {
  const CardFortunePage({super.key});

  @override
  State<CardFortunePage> createState() => _CardFortunePageState();
}

class _CardFortunePageState extends State<CardFortunePage> with TickerProviderStateMixin {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();
  final FocusNode textFocusNode = FocusNode();
  final TextEditingController textController = TextEditingController();

  CardModel? selectedCard;
  bool isAnimating = false;

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _clearFocus() {
    if (textFocusNode.hasFocus) {
      textFocusNode.unfocus();
    }
  }

  void _randomizeCard() {
    final question = textController.text.trim();
    if (question.isEmpty) {
      Get.snackbar(
        'กรุณากรอกสิ่งที่คุณอยากรู้',
        'โปรดพิมพ์สิ่งที่คุณอยากรู้ก่อนสุ่มไพ่',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (appController.cards.isEmpty || isAnimating) return;

    setState(() {
      isAnimating = true;
      selectedCard = null;
    });
  }

  List<CardModel> _getShuffleCards() {
    if (appController.cards.isEmpty) return [];

    List<CardModel> shuffleCards = appController.cards.where((card) {
      String thName = card.name.th.toLowerCase();
      return thName.contains("พระพิฆเนศ") || thName.contains("พระราหู");
    }).toList();

    return shuffleCards;
  }

  void _onAnimationComplete(int selectedCardIndex) {
    final shuffleCards = _getShuffleCards();

    if (shuffleCards.isEmpty) {
      setState(() {
        isAnimating = false;
      });
      return;
    }

    if (selectedCardIndex >= 0 && selectedCardIndex < shuffleCards.length) {
      setState(() {
        selectedCard = shuffleCards[selectedCardIndex];
        isAnimating = false;
      });
    } else {
      final random = Random();
      final randomIndex = random.nextInt(shuffleCards.length);
      setState(() {
        selectedCard = shuffleCards[randomIndex];
        isAnimating = false;
      });
    }
  }

  void _predictFortune() {
    final question = textController.text.trim();
    if (question.isEmpty) {
      Get.snackbar(
        'กรุณากรอกสิ่งที่คุณอยากรู้',
        'โปรดพิมพ์สิ่งที่คุณอยากรู้ก่อนทำนาย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCard == null) {
      Get.snackbar(
        'กรุณาเลือกไพ่',
        'โปรดสุ่มไพ่ก่อนทำนาย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.toNamed(
      RoutePath.geminiPrediction,
      arguments: {
        'cardItem': selectedCard,
        'question': question,
        'promptType': PromptType.fortune,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearFocus,
      child: CommonLayout(
        title: 'ไพ่เสี่ยงทาย',
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
                      textController: textController,
                      textFocusNode: textFocusNode,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สุ่มไพ่ 1 ใบ',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: isAnimating ? null : _randomizeCard,
                            child: Container(
                              width: 200,
                              height: 300,
                              decoration: BoxDecoration(
                                color: isAnimating || selectedCard != null ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAnimating || selectedCard != null ? Colors.transparent : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isAnimating
                                  ? CardShuffleAnimation(
                                      isAnimating: isAnimating,
                                      onAnimationComplete: _onAnimationComplete,
                                      cards: _getShuffleCards(),
                                    )
                                  : _buildCardDisplay(),
                            ),
                          ),
                        ),
                        if (selectedCard != null && !isAnimating) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton.icon(
                              onPressed: _randomizeCard,
                              icon: const Icon(Icons.restart_alt_outlined),
                              label: Text(
                                'สุ่มใหม่',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    RainbowBorderButton(
                      title: 'ทำนาย',
                      icon: Icons.auto_awesome_outlined,
                      onPressed: _predictFortune,
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

  Widget _buildCardDisplay() {
    if (selectedCard != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.network(
              selectedCard!.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildCardFallback();
              },
            ),
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.grey,
            size: 40,
          ),
          SizedBox(height: 12),
          Text(
            'กดที่นี่เพื่อสุ่มไพ่',
            style: Theme.of(context).textTheme.labelLarge,
          )
        ],
      );
    }
  }

  Widget _buildCardFallback() {
    if (selectedCard == null) return const SizedBox();

    final String nameText = selectedCard!.name.th.isNotEmpty ? selectedCard!.name.th : selectedCard!.name.en;

    final int asciiValue = nameText.isEmpty ? 65 : nameText.codeUnitAt(0);
    final hue = (asciiValue % 360).toDouble();

    final startColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.4).toColor();
    final endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.7, 0.5).toColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                nameText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionInputSection extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode textFocusNode;

  const QuestionInputSection({
    super.key,
    required this.textController,
    required this.textFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สิ่งที่ต้องการอยากรู้',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'ตัวอย่าง: "ธุรกิจจะประสบความสำเร็จหรือไม่?"',
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
            controller: textController,
            focusNode: textFocusNode,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'พิมพ์สิ่งที่คุณอยากรู้...',
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
