import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/models/card_model.dart';

class CardShuffleAnimation extends StatefulWidget {
  const CardShuffleAnimation({
    super.key,
    required this.isAnimating,
    required this.onAnimationComplete,
    required this.cards,
    this.spinDurationMs = 3000,
    this.effectsDurationMs = 5000,
    this.pauseDurationMs = 0,
    this.endDelayMs = 0,
  });

  final bool isAnimating;
  final Function(int selectedCardIndex) onAnimationComplete;
  final List<CardModel> cards;

  final int spinDurationMs;
  final int effectsDurationMs;
  final int pauseDurationMs;
  final int endDelayMs;

  @override
  State<CardShuffleAnimation> createState() => _CardShuffleAnimationState();
}

class _CardShuffleAnimationState extends State<CardShuffleAnimation> with TickerProviderStateMixin {
  late AnimationController reelController;
  late Animation<double> reelPositionAnimation;
  late Animation<double> reelBlurAnimation;

  late AnimationController effectsController;
  late Animation<double> glowAnimation;
  late Animation<double> flashAnimation;

  final int imagesPerReel = 15;

  int selectedCardIndex = 0;

  List<int> cardIndices = [];

  bool _internalAnimating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    if (widget.isAnimating && !_internalAnimating) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(CardShuffleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.spinDurationMs != oldWidget.spinDurationMs || widget.effectsDurationMs != oldWidget.effectsDurationMs) {
      reelController.dispose();
      effectsController.dispose();
      _initAnimations();
    }

    if (widget.isAnimating && !oldWidget.isAnimating && !_internalAnimating) {
      _startAnimation();
    }
  }

  void _initAnimations() {
    reelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.spinDurationMs),
    );

    reelPositionAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0 * imagesPerReel.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: reelController,
        curve: Curves.easeOutBack,
      ),
    );

    reelBlurAnimation = Tween<double>(
      begin: 5.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: reelController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    effectsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.effectsDurationMs),
    );

    glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: effectsController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: effectsController,
        curve: const Interval(0.85, 0.95, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _startAnimation() async {
    if (_internalAnimating) return;

    _internalAnimating = true;

    effectsController.reset();
    reelController.reset();

    _generateRandomCardIndices();

    final random = Random();
    selectedCardIndex = widget.cards.isEmpty ? 0 : random.nextInt(widget.cards.length);

    reelController.forward();

    await reelController.forward();

    await Future.delayed(Duration(milliseconds: widget.pauseDurationMs));

    effectsController.forward();

    await Future.delayed(Duration(milliseconds: widget.endDelayMs));

    _internalAnimating = false;

    widget.onAnimationComplete(selectedCardIndex);
  }

  void _generateRandomCardIndices() {
    if (widget.cards.isEmpty) return;

    final random = Random();
    cardIndices = List.generate(imagesPerReel, (index) => random.nextInt(widget.cards.length));
  }

  @override
  void dispose() {
    reelController.dispose();
    effectsController.dispose();
    super.dispose();
  }

  Widget _buildCardImage(int index, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    if (widget.cards.isEmpty) {
      return _buildFallbackCard(index, width, height);
    }

    final cardIndex = index % widget.cards.length;
    final card = widget.cards[cardIndex];

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.06),
        child: Image.network(
          card.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildCardWithName(card, width, height);
          },
        ),
      ),
    );
  }

  Widget _buildCardWithName(CardModel card, double width, double height) {
    final int asciiValue = card.name.en.isEmpty
        ? card.name.th.isEmpty
            ? 65
            : card.name.th.codeUnitAt(0)
        : card.name.en.codeUnitAt(0);

    final hue = (asciiValue % 360).toDouble();
    final startColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.4).toColor();
    final endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.7, 0.5).toColor();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.9),
                size: width * 0.2,
              ),
              SizedBox(height: height * 0.05),
              Text(
                card.name.th.isNotEmpty ? card.name.th : card.name.en,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackCard(int index, double width, double height) {
    final cardColors = [
      [Colors.red.shade700, Colors.redAccent.shade700],
      [Colors.purple.shade800, Colors.purpleAccent.shade700],
      [Colors.blue.shade700, Colors.blueAccent.shade700],
      [Colors.indigo.shade800, Colors.indigoAccent.shade700],
      [Colors.teal.shade700, Colors.tealAccent.shade700],
      [Colors.orange.shade800, Colors.orangeAccent.shade700],
    ];

    final colorPair = cardColors[index % cardColors.length];

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorPair[0], colorPair[1]],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorPair[1].withOpacity(0.8),
                colorPair[0].withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.9),
                  size: width * 0.25,
                ),
                SizedBox(height: height * 0.05),
                Text(
                  'ไพ่ ${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.12,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReel(double position, double blur, BoxConstraints constraints) {
    final cardPositions = <Widget>[];

    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final cardHeight = height;
    final cardMargin = 8.0;
    final totalCardHeight = cardHeight + cardMargin;

    for (int i = 0; i < imagesPerReel; i++) {
      int cardIndex;
      if (reelController.isCompleted) {
        cardIndex = (i == imagesPerReel ~/ 2) ? selectedCardIndex : cardIndices[i % cardIndices.length];
      } else {
        cardIndex = cardIndices[i % cardIndices.length];
      }

      double offset = (i * totalCardHeight) - (position % 1.0) * totalCardHeight;

      cardPositions.add(
        Positioned(
          top: offset,
          left: 0,
          right: 0,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
            ),
            child: _buildCardImage(
                cardIndex,
                BoxConstraints(
                  maxWidth: width,
                  maxHeight: cardHeight,
                )),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: cardHeight,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: cardPositions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: Listenable.merge([reelController, effectsController]),
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(constraints.maxWidth * 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(glowAnimation.value * 0.3),
                    spreadRadius: glowAnimation.value * 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: _buildReel(
                        reelPositionAnimation.value,
                        reelBlurAnimation.value,
                        BoxConstraints(
                          maxWidth: constraints.maxWidth,
                          maxHeight: constraints.maxHeight,
                        ),
                      ),
                    ),
                  ),
                  if (flashAnimation.value > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: flashAnimation.value * 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.white, Colors.transparent],
                              radius: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(constraints.maxWidth * 0.08),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: effectsController,
                      builder: (context, child) {
                        if (glowAnimation.value < 0.7) {
                          return const SizedBox.shrink();
                        }

                        final opacity = (glowAnimation.value - 0.7) * 3.3;

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.025),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(constraints.maxWidth * 0.08),
                              bottomRight: Radius.circular(constraints.maxWidth * 0.08),
                            ),
                          ),
                          child: Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Text(
                              'ทำนายสำเร็จ!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
