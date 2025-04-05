import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/models/card_model.dart';
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
    if (appController.cards.isEmpty || isAnimating) return;

    setState(() {
      isAnimating = true;
      selectedCard = null; // Hide the current card during animation
    });
  }

  // จะถูกเรียกเมื่อแอนิเมชันเสร็จสิ้น
  void _onAnimationComplete() {
    // เลือกไพ่สุ่ม
    final random = Random();
    final randomIndex = random.nextInt(appController.cards.length);

    setState(() {
      selectedCard = appController.cards[randomIndex];
      isAnimating = false;
    });
  }

  void _predictFortune() {
    final question = textController.text.trim();
    if (question.isEmpty) {
      Get.snackbar(
        'กรุณากรอกคำถาม',
        'โปรดพิมพ์คำถามที่คุณต้องการคำตอบก่อนทำนาย',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // ตรงนี้คุณสามารถทำการทำนายได้
    // ...
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
                    // ส่วนกรอกคำถาม
                    QuestionInputSection(
                      textController: textController,
                      textFocusNode: textFocusNode,
                    ),
                    const SizedBox(height: 16),

                    // ส่วนแสดงไพ่
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สุ่มไพ่ 1 ใบ',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // พื้นที่ตรงกลางสำหรับการแสดงไพ่หรือการสุ่ม
                        Center(
                          child: GestureDetector(
                            onTap: isAnimating ? null : _randomizeCard,
                            child: Container(
                              width: 200,
                              height: 300,
                              decoration: BoxDecoration(
                                color: isAnimating ? null : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAnimating || selectedCard != null ? Colors.transparent : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              // ใช้ isAnimating เพื่อสลับระหว่างการแสดงปกติและแอนิเมชัน
                              child: isAnimating
                                  ? CardShuffleAnimation(
                                      isAnimating: isAnimating,
                                      onAnimationComplete: _onAnimationComplete,
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

                    // ปุ่มทำนาย
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

  // Widget แสดงไพ่หรือข้อความให้กดสุ่ม
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
                return const Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: Colors.amber,
                );
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
}

// คลาสแยกสำหรับส่วนกรอกคำถาม
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
            controller: textController,
            focusNode: textFocusNode,
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
