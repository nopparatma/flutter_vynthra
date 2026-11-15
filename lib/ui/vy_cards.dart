import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vynthra/models/card_model.dart';

import 'vy.dart';

/// Face of a card. Most cards in the deck have no picture yet, so those show a cream face with a gold star.
class VyCardFace extends StatelessWidget {
  final CardModel card;
  final double radius;
  final double starSize;

  const VyCardFace({super.key, required this.card, this.radius = 6, this.starSize = 20});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        color: Vy.cardCream,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.auto_awesome, color: const Color(0xFFB8892E), size: starSize),
    );
    if (card.imageUrl.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        card.imageUrl,
        // S3 serves the card images without CORS headers; on web fall back to an <img> element.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => fallback,
      ),
    );
  }
}

class VyCardBack extends StatelessWidget {
  final double radius;
  const VyCardBack({super.key, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(Vy.cardBack, fit: BoxFit.cover),
    );
  }
}

/// The card held up in the middle: a double gold frame and a warm glow.
class VyRaisedCard extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;

  const VyRaisedCard({super.key, required this.card, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Vy.goldPale.withValues(alpha: 0.55), blurRadius: 60),
          BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 50, offset: const Offset(0, 22)),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Vy.gold, width: 2),
      ),
      child: VyCardFace(card: card, radius: 10, starSize: 34),
    );
  }
}

/// Sunburst halo drawn behind a raised card: the motif of the card backs.
class VyHaloPainter extends CustomPainter {
  final Offset center;
  final double radius;

  VyHaloPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(colors: [
        Vy.goldPale.withValues(alpha: 0.5),
        Vy.gold.withValues(alpha: 0.2),
        Vy.gold.withValues(alpha: 0),
      ], stops: const [0, 0.6, 1])
          .createShader(Rect.fromCircle(center: center, radius: radius + 43));
    canvas.drawCircle(center, radius + 43, glow);
    canvas.drawCircle(center, radius, Paint()..color = const Color(0x8C080710));
    canvas.drawCircle(center, radius, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Vy.gold.withValues(alpha: 0.95));
    canvas.drawCircle(center, radius - 8, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Vy.gold.withValues(alpha: 0.5));
    for (var j = 0; j < 36; j++) {
      final a = j * 10 * math.pi / 180;
      final long = j % 3 == 0;
      final r1 = radius + 6, r2 = radius + (long ? 22 : 14);
      final d = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(center + d * r1, center + d * r2, Paint()
        ..strokeWidth = long ? 1.4 : 1
        ..color = Vy.gold.withValues(alpha: long ? 0.85 : 0.5));
    }
  }

  @override
  bool shouldRepaint(VyHaloPainter old) => old.center != center || old.radius != radius;
}

/// Round pad for one thumb. [progress] 0..1 draws the gold ring as the hold goes on.
class VyThumbPad extends StatelessWidget {
  final double progress;
  final String side;
  final ValueChanged<bool> onHold;

  const VyThumbPad({super.key, required this.progress, required this.side, required this.onHold});

  @override
  Widget build(BuildContext context) {
    final held = progress > 0;
    return Semantics(
      button: true,
      label: 'วางนิ้วโป้ง$sideค้างไว้',
      child: Listener(
        onPointerDown: (_) => onHold(true),
        onPointerUp: (_) => onHold(false),
        onPointerCancel: (_) => onHold(false),
        child: SizedBox(
          width: 96,
          height: 96,
          child: CustomPaint(
            painter: _PadRing(progress),
            child: Padding(
              padding: EdgeInsets.all(held ? 4 : 1.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: held ? const RadialGradient(colors: [Color(0xFF3A2F18), Color(0xFF14101F)], stops: [0, 0.78]) : null,
                  color: held ? null : const Color(0xFF0C0B16),
                  boxShadow: [BoxShadow(color: Vy.gold.withValues(alpha: held ? 0.7 : 0.32), blurRadius: held ? 44 : 26)],
                ),
                child: Icon(Icons.fingerprint_rounded, size: 40, color: held ? Vy.goldPale : const Color(0xFFF6E7B4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PadRing extends CustomPainter {
  final double progress;
  _PadRing(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (progress <= 0) {
      canvas.drawOval(rect, Paint()..shader = Vy.ringFill.createShader(rect));
      return;
    }
    canvas.drawOval(rect, Paint()..color = Colors.white.withValues(alpha: 0.16));
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, true,
        Paint()..shader = const SweepGradient(colors: [Vy.goldPale, Color(0xFFE3B95C)]).createShader(rect));
  }

  @override
  bool shouldRepaint(_PadRing old) => old.progress != progress;
}
