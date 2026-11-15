import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Colours, type and the small set of surfaces the cosmic redesign is built from.
class Vy {
  Vy._();

  static const Color ink = Color(0xFF05060A);
  static const Color text = Color(0xFFF4F1EA);
  static const Color textSoft = Color(0xFFE4DFD4);
  static const Color textMuted = Color(0xFFD4CFC4);
  static const Color gold = Color(0xFFE9D18B);
  static const Color goldDeep = Color(0xFFC9963A);
  static const Color goldPale = Color(0xFFFBEFC4);
  static const Color onGold = Color(0xFF14122B);
  static const Color violet = Color(0xFF8E6BE8);
  static const Color cardCream = Color(0xFFF3EBD8);

  static const String nebula = 'assets/images/cosmos/nebula.jpg';
  static const String eclipse = 'assets/images/cosmos/eclipse.jpg';
  static const String galaxy = 'assets/images/cosmos/galaxy.jpg';
  static const String cardBack = 'assets/images/cosmos/card_back.png';
  static const String logo = 'assets/images/vynthra_logo.png';

  static const LinearGradient goldFill = LinearGradient(
    begin: Alignment(-1, -0.4),
    end: Alignment(1, 0.4),
    colors: [goldPale, Color(0xFFE3B95C), goldDeep],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient ringFill = LinearGradient(
    begin: Alignment(-1, -0.4),
    end: Alignment(1, 0.4),
    colors: [goldPale, Color(0xFFD9A84A), violet],
    stops: [0, 0.38, 1],
  );

  static TextStyle t(double size, {bool bold = false, Color color = text, double height = 1.4}) =>
      TextStyle(fontFamily: 'Cloud', fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: color, height: height);
}

/// Full-screen background image with an optional dark wash on top.
class VyBackground extends StatelessWidget {
  final String image;
  final double scrim;
  final Widget child;

  const VyBackground({super.key, this.image = Vy.nebula, this.scrim = 0.42, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vy.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(image, fit: BoxFit.cover),
          if (scrim > 0) ColoredBox(color: Vy.ink.withValues(alpha: scrim)),
          child,
        ],
      ),
    );
  }
}

/// Frosted glass surface used for menus, sheets and the pager.
class VyGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double tint;

  const VyGlass({super.key, required this.child, this.radius = 28, this.padding = EdgeInsets.zero, this.tint = 0.07});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: tint),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Screen title with a back arrow, sitting under the status bar.
class VyHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const VyHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(title, style: Vy.t(20, bold: true)),
          Positioned(
            left: 4,
            child: IconButton(
              tooltip: 'ย้อนกลับ',
              onPressed: onBack ?? () => Get.back(),
              icon: const Icon(Icons.chevron_left_rounded, color: Vy.text, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

/// The one action that moves the reading forward: solid gold.
class VyGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const VyGoldButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: Vy.goldFill,
            borderRadius: BorderRadius.circular(29),
            boxShadow: [BoxShadow(color: Vy.gold.withValues(alpha: 0.5), blurRadius: 30)],
          ),
          child: Text(label, style: Vy.t(18, bold: true, color: Vy.onGold)),
        ),
      ),
    );
  }
}

/// Two equal ways out, side by side in one glass capsule.
class VyGlassPair extends StatelessWidget {
  final String left;
  final String right;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const VyGlassPair({super.key, required this.left, required this.right, required this.onLeft, required this.onRight});

  @override
  Widget build(BuildContext context) {
    Widget half(String label, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: Center(child: Text(label, style: Vy.t(16.5, bold: true))),
          ),
        );
    return SizedBox(
      height: 58,
      child: VyGlass(
        radius: 29,
        tint: 0.1,
        child: Row(children: [
          half(left, onLeft),
          Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.26)),
          half(right, onRight),
        ]),
      ),
    );
  }
}

/// Soft fade behind the controls at the foot of a screen.
class VyFootFade extends StatelessWidget {
  final double height;
  const VyFootFade({super.key, this.height = 216});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Vy.ink.withValues(alpha: 0), Vy.ink.withValues(alpha: 0.8)],
            stops: const [0, 0.45],
          ),
        ),
      ),
    );
  }
}

/// Thin gold progress line with a caption above it.
class VyProgress extends StatelessWidget {
  final String label;
  final double value;
  final bool live;

  const VyProgress({super.key, required this.label, required this.value, this.live = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 264,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: Vy.t(15, color: Vy.textSoft)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(children: [
            Container(height: 6, color: Colors.white.withValues(alpha: 0.18)),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 600),
              widthFactor: value.clamp(0, 1),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: live ? const LinearGradient(colors: [Vy.goldDeep, Vy.goldPale]) : null,
                  color: live ? null : Vy.gold.withValues(alpha: 0.6),
                  boxShadow: live ? [BoxShadow(color: Vy.gold.withValues(alpha: 0.7), blurRadius: 10)] : null,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
