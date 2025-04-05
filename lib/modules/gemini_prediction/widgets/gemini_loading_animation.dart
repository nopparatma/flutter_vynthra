import 'package:flutter/material.dart';

class GeminiLoadingAnimation extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final Duration blinkDuration;

  const GeminiLoadingAnimation({
    super.key,
    required this.imagePath,
    this.width = 200,
    this.height = 200,
    this.blinkDuration = const Duration(seconds: 2),
  });

  @override
  State<GeminiLoadingAnimation> createState() => _GeminiLoadingAnimationState();
}

class _GeminiLoadingAnimationState extends State<GeminiLoadingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.blinkDuration,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.3, // You can adjust this value to control how dim the image gets
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Set up the animation to repeat in both directions
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}