import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vynthra/app/app_theme.dart';

class CardShuffleAnimation extends StatefulWidget {
  const CardShuffleAnimation({
    Key? key,
    required this.isAnimating,
    required this.onAnimationComplete,
    this.spinDurationMs = 3000, // ระยะเวลาการหมุน (มิลลิวินาที)
    this.effectsDurationMs = 5000, // ระยะเวลาเอฟเฟกต์ (มิลลิวินาที)
    this.pauseDurationMs = 0, // ระยะเวลาหยุดระหว่างหมุนกับแสดงเอฟเฟกต์ (มิลลิวินาที)
    this.endDelayMs = 0, // ระยะเวลารอก่อนจบ (มิลลิวินาที)
  }) : super(key: key);

  final bool isAnimating;
  final VoidCallback onAnimationComplete;

  // พารามิเตอร์กำหนดเวลา
  final int spinDurationMs;
  final int effectsDurationMs;
  final int pauseDurationMs;
  final int endDelayMs;

  @override
  State<CardShuffleAnimation> createState() => _CardShuffleAnimationState();
}

class _CardShuffleAnimationState extends State<CardShuffleAnimation> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController reelController;
  late Animation<double> reelPositionAnimation;
  late Animation<double> reelBlurAnimation;

  // Flash and glow effects
  late AnimationController effectsController;
  late Animation<double> glowAnimation;
  late Animation<double> flashAnimation;

  // Number of card images in the reel
  final int imagesPerReel = 15;

  // Card selection for final result
  int selectedCardIndex = 0;

  bool _internalAnimating = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Start animation when isAnimating changes to true
    if (widget.isAnimating && !_internalAnimating) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(CardShuffleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ถ้ามีการเปลี่ยนแปลงค่าระยะเวลา ให้สร้าง animations ใหม่
    if (widget.spinDurationMs != oldWidget.spinDurationMs || widget.effectsDurationMs != oldWidget.effectsDurationMs) {
      // ต้องกำจัด controllers เก่าก่อน
      reelController.dispose();
      effectsController.dispose();
      // สร้าง animations ใหม่
      _initAnimations();
    }

    // Check if the animation flag changed
    if (widget.isAnimating && !oldWidget.isAnimating && !_internalAnimating) {
      _startAnimation();
    }
  }

  void _initAnimations() {
    // Single reel controller - ใช้ค่าระยะเวลาจาก widget
    reelController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.spinDurationMs),
    );

    // Reel position animation - simulate slot machine spinning
    reelPositionAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0 * imagesPerReel.toDouble(), // Spin multiple times
    ).animate(
      CurvedAnimation(
        parent: reelController,
        curve: Curves.easeOutBack, // Slow down at the end like a real slot machine
      ),
    );

    // Blur effect for spinning reel
    reelBlurAnimation = Tween<double>(
      begin: 5.0, // Start blurry
      end: 0.0, // End clear
    ).animate(
      CurvedAnimation(
        parent: reelController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Effects controller for glow and flash - ใช้ค่าระยะเวลาจาก widget
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

    // Reset animations
    effectsController.reset();
    reelController.reset();

    // Randomly select final card index
    final random = Random();
    selectedCardIndex = random.nextInt(6); // Assuming 6 different card types

    // Start reel spinning
    reelController.forward();

    // รอให้การหมุนเสร็จสิ้น (ใช้ await)
    await reelController.forward();

    // Small pause for drama - ใช้ค่าระยะเวลาจาก widget
    await Future.delayed(Duration(milliseconds: widget.pauseDurationMs));

    // Play success effects
    effectsController.forward();

    // Wait for effects to play - ใช้ค่าระยะเวลาจาก widget
    await Future.delayed(Duration(milliseconds: widget.endDelayMs));

    _internalAnimating = false;

    // Notify parent that animation is complete
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    reelController.dispose();
    effectsController.dispose();
    super.dispose();
  }

  Widget _buildCardImage(int index, BoxConstraints constraints) {
    // Calculate dimensions based on constraints
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Different card styles based on index
    final cardColors = [
      [Colors.red.shade700, Colors.redAccent.shade700],
      [Colors.purple.shade800, Colors.purpleAccent.shade700],
      [Colors.blue.shade700, Colors.blueAccent.shade700],
      [Colors.indigo.shade800, Colors.indigoAccent.shade700],
      [Colors.teal.shade700, Colors.tealAccent.shade700],
      [Colors.orange.shade800, Colors.orangeAccent.shade700],
    ];

    final colorPair = cardColors[index % cardColors.length];

    // ปรับขนาดไพ่ให้พอดีกับพื้นที่ที่ได้รับ
    final cardWidth = width;
    final cardHeight = height;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06), // ปรับขนาด borderRadius ตามสัดส่วน
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorPair[0],
            colorPair[1],
          ],
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
          width: cardWidth,
          height: cardHeight,
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
                  size: width * 0.25, // ปรับขนาดไอคอนตามขนาดไพ่
                ),
                SizedBox(height: height * 0.05),
                Text(
                  'ไพ่ ${index + 1}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.12, // ปรับขนาดตัวอักษรตามขนาดไพ่
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a single reel for the slot machine that fills the container
  Widget _buildReel(double position, double blur, BoxConstraints constraints) {
    final cardPositions = <Widget>[];

    // Calculate card dimensions based on container size
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final cardHeight = height;
    final cardMargin = 8.0; // ระยะห่างระหว่างไพ่
    final totalCardHeight = cardHeight + cardMargin;

    // Add cards to the reel
    for (int i = 0; i < imagesPerReel; i++) {
      // Calculate card index - use the selected card at the end
      int cardIndex;
      if (reelController.isCompleted) {
        cardIndex = (i == imagesPerReel ~/ 2) ? selectedCardIndex : (i + selectedCardIndex) % 6;
      } else {
        cardIndex = (i + position.floor()) % 6;
      }

      // Calculate position offset
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
              // Container จะยืดเต็มพื้นที่ที่ได้รับจาก parent
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
                  // Slot machine reel in the center
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

                  // Flash effect overlay
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

                  // Success message at the bottom
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
