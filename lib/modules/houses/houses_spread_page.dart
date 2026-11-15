import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';
import 'package:vynthra/ui/vy_cards.dart';

import 'houses_controller.dart';

/// The wheel of twelve houses, from the laying of the cards to choosing one to read.
/// Drawn on a 440 x 676 design box that scales to the screen, so it keeps the proportions of the canvas.
class HousesSpreadPage extends StatelessWidget {
  const HousesSpreadPage({super.key});

  static const double boxW = 440, boxH = 676;
  static const Offset center = Offset(220, 348);
  static const double rx = 162, ry = 236;

  static Rect cardRect(int i) {
    final a = (i + 1) * 30 * math.pi / 180;
    final size = i == 11 ? const Size(66, 119) : const Size(58, 90);
    final c = center + Offset(rx * math.sin(a), -ry * math.cos(a));
    return Rect.fromCenter(center: c, width: size.width, height: size.height);
  }

  void _leave() {
    Get.delete<HousesController>(force: true);
    Get.until((r) => r.settings.name == RoutePath.homePage);
  }

  @override
  Widget build(BuildContext context) {
    if (housesReadingMissing()) return const ColoredBox(color: Vy.ink);
    final c = Get.find<HousesController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: VyBackground(
        scrim: 0.5,
        child: SafeArea(
          child: Obx(() {
            final phase = c.phase.value;
            final placed = c.placed.value, revealed = c.revealed.value;
            final sel = c.selected.value;
            final read = c.readSet.toSet();
            final active = sel ?? (phase == HousesPhase.dealing ? placed - 1 : (phase == HousesPhase.open ? null : revealed - (phase == HousesPhase.paused ? 0 : 1)));
            return Column(children: [
              VyHeader(title: 'ไพ่ 12 เรือน', onBack: _leave),
              Expanded(
                child: FittedBox(
                  child: SizedBox(
                    width: boxW,
                    height: boxH,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned.fill(child: CustomPaint(painter: _DialPainter(active: active))),
                      if (phase == HousesPhase.revealing && revealed > 0)
                        Positioned.fill(child: CustomPaint(painter: VyHaloPainter(center: const Offset(220, 308), radius: 107))),
                      if (sel != null) Positioned.fill(child: CustomPaint(painter: VyHaloPainter(center: const Offset(220, 278), radius: 96))),
                      for (var i = 0; i < HousesController.count; i++) ..._card(c, i, phase, placed, revealed, sel, read),
                      ..._centre(c, phase, placed, revealed, sel),
                    ]),
                  ),
                ),
              ),
              SizedBox(height: 126, child: _foot(c, phase, placed, revealed, sel)),
            ]);
          }),
        ),
      ),
    );
  }

  List<Widget> _card(HousesController c, int i, HousesPhase phase, int placed, int revealed, int? sel, Set<int> read) {
    final r = cardRect(i);
    final key = i == 0 || i == 11;
    final faceUp = i < revealed;
    final stalled = phase == HousesPhase.paused && i == revealed;
    final dim = sel != null && i != sel;
    final hot = (phase == HousesPhase.dealing && i == placed - 1) || (phase == HousesPhase.revealing && i == revealed - 1) || stalled;
    final out = <Widget>[];

    Widget body;
    if (sel == i) {
      body = _dashed(gold: true);
    } else if (phase == HousesPhase.dealing && i >= placed) {
      body = _dashed(gold: key);
    } else if (faceUp) {
      body = GestureDetector(onTap: () => c.tapCard(i), child: VyCardFace(card: c.cards[i]));
    } else {
      body = ColorFiltered(
        colorFilter: phase == HousesPhase.paused && !stalled ? const ColorFilter.mode(Color(0x73000000), BlendMode.srcATop) : const ColorFilter.mode(Color(0x00000000), BlendMode.srcATop),
        child: const VyCardBack(),
      );
    }
    final shadow = hot
        ? [BoxShadow(color: Vy.gold, spreadRadius: 2), BoxShadow(color: Vy.gold.withValues(alpha: stalled ? 0.85 : 0.65), blurRadius: stalled ? 30 : 20)]
        : [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 14, offset: const Offset(0, 6))];
    out.add(Positioned.fromRect(
      rect: r,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: dim ? 0.36 : 1,
        child: Semantics(
          button: faceUp,
          label: 'เรือน${c.positions[i].name.th} ${faceUp ? 'ไพ่${c.cards[i].name.th}' : ''}${read.contains(i) ? ' อ่านแล้ว' : ''}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: sel == i ? null : shadow,
              border: key && !hot && sel != i && !(phase == HousesPhase.dealing && i >= placed) ? Border.all(color: Vy.gold.withValues(alpha: 0.85), width: 1.5) : null,
            ),
            child: body,
          ),
        ),
      ),
    ));
    if (read.contains(i) && sel != i) {
      out.add(Positioned(
        left: r.right - 15,
        top: r.top - 7,
        child: Opacity(
          opacity: dim ? 0.36 : 1,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: Vy.gold, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 15, color: Vy.onGold),
          ),
        ),
      ));
    }
    // the base of the chart and the summary card keep a gold name above them; the others are named once turned
    final label = houseShort[i];
    final labelStyle = Vy.t(14, bold: key || hot, color: key || hot ? Vy.gold : Vy.text, height: 1.3)
        .copyWith(shadows: const [Shadow(color: Vy.ink, blurRadius: 6)]);
    if (key) {
      out.add(Positioned(left: r.left - 14, width: r.width + 28, top: r.top - 23, child: Opacity(opacity: dim ? 0.36 : 1, child: Text(label, textAlign: TextAlign.center, style: labelStyle))));
    } else if (faceUp || stalled) {
      out.add(Positioned(left: r.left - 14, width: r.width + 28, top: r.bottom + 4, child: Opacity(opacity: dim ? 0.36 : 1, child: Text(label, textAlign: TextAlign.center, style: labelStyle))));
    }
    return out;
  }

  Widget _dashed({required bool gold}) => CustomPaint(
        painter: _DashedRect(gold ? Vy.gold.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.3)),
        child: Container(color: gold ? Vy.gold.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03)),
      );

  List<Widget> _centre(HousesController c, HousesPhase phase, int placed, int revealed, int? sel) {
    final shade = [const Shadow(color: Vy.ink, blurRadius: 10), const Shadow(color: Vy.ink, blurRadius: 18)];
    Widget box(List<Widget> children, {double top = 248, double h = 200}) => Positioned(
          left: 96,
          width: 248,
          top: top,
          height: h,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: children),
        );
    switch (phase) {
      case HousesPhase.dealing:
        final n = placed.clamp(1, 12);
        return [
          box([
            Text('วางไพ่ลงเรือน', style: Vy.t(15, color: Vy.textSoft)),
            const SizedBox(height: 6),
            Text(c.positions[n - 1].name.th, textAlign: TextAlign.center, style: Vy.t(25, bold: true, height: 1.3).copyWith(shadows: shade)),
            const SizedBox(height: 10),
            Text('ใบที่ $n จาก 12', style: Vy.t(14, color: const Color(0xFFC9C4D4))),
          ]),
        ];
      case HousesPhase.revealing:
        if (revealed == 0) {
          return [box([Text('กำลังเปิดไพ่ใบแรก', style: Vy.t(18, bold: true).copyWith(shadows: shade))])];
        }
        final i = revealed - 1;
        return [
          Positioned(left: 164, top: 206, child: VyRaisedCard(card: c.cards[i], width: 112, height: 204)),
          Positioned(
            left: 60,
            width: 320,
            top: 450,
            child: Column(children: [
              Text('เรือน${c.positions[i].name.th}', textAlign: TextAlign.center, style: Vy.t(23, bold: true, height: 1.25).copyWith(shadows: shade)),
              Text(c.cards[i].name.th, textAlign: TextAlign.center, style: Vy.t(16, bold: true, color: Vy.gold).copyWith(shadows: shade)),
            ]),
          ),
        ];
      case HousesPhase.paused:
        return [
          Positioned(
            left: 70,
            top: 202,
            width: 300,
            height: 292,
            child: const DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(colors: [Color(0xD105060A), Color(0x8C05060A), Color(0x0005060A)], stops: [0, 0.55, 1]))),
          ),
          box([
            const Icon(Icons.nightlight_round, color: Vy.gold, size: 40),
            const SizedBox(height: 14),
            Text('ไพ่ใบนี้\nยังเปิดไม่ได้', textAlign: TextAlign.center, style: Vy.t(25, bold: true, height: 1.3).copyWith(shadows: shade)),
            const SizedBox(height: 10),
            Text('การเชื่อมต่อขาดหายไป\nไพ่ทั้ง 12 ใบของคุณยังอยู่ครบ', textAlign: TextAlign.center, style: Vy.t(16, height: 1.55).copyWith(shadows: shade)),
          ], top: 230, h: 240),
        ];
      case HousesPhase.open:
        if (sel == null) {
          return [
            box([
              Text('ไพ่ 12 เรือน\nของคุณ', textAlign: TextAlign.center, style: Vy.t(20, bold: true, height: 1.3)),
              const SizedBox(height: 8),
              Text('แต่ละเรือน\nเล่าชีวิตหนึ่งด้าน', textAlign: TextAlign.center, style: Vy.t(15, color: Vy.textMuted, height: 1.5)),
            ]),
          ];
        }
        return [
          Positioned(
            left: 168,
            top: 184,
            child: GestureDetector(onTap: () => c.tapCard(sel), child: VyRaisedCard(card: c.cards[sel], width: 104, height: 188)),
          ),
          Positioned(
            left: 96,
            width: 248,
            top: 402,
            child: Column(children: [
              Text('เรือน${c.positions[sel].name.th}', textAlign: TextAlign.center, style: Vy.t(21, bold: true, height: 1.3).copyWith(shadows: shade)),
              Text(houseAbout[sel], textAlign: TextAlign.center, style: Vy.t(14.5, height: 1.35).copyWith(shadows: shade)),
              Text(c.cards[sel].name.th, textAlign: TextAlign.center, style: Vy.t(15, color: Vy.gold).copyWith(shadows: shade)),
              const SizedBox(height: 6),
              Text('แตะไพ่ใบอื่นเพื่อเปลี่ยนเรื่อง', style: Vy.t(14, color: Vy.textSoft).copyWith(shadows: shade)),
            ]),
          ),
        ];
    }
  }

  Widget _foot(HousesController c, HousesPhase phase, int placed, int revealed, int? sel) {
    Widget slot({Widget? info, Widget? action}) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            SizedBox(height: 38, child: Center(child: info)),
            const SizedBox(height: 12),
            SizedBox(height: 58, child: action),
          ]),
        );
    switch (phase) {
      case HousesPhase.dealing:
      case HousesPhase.revealing:
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Align(alignment: Alignment.bottomCenter, child: VyProgress(label: 'กำลังอ่านไพ่ของคุณ', value: (placed + revealed) / 24)),
        );
      case HousesPhase.paused:
        return slot(
          info: VyProgress(label: 'หยุดไว้ที่ไพ่ใบที่ ${revealed + 1} จาก 12', value: (12 + revealed) / 24, live: false),
          action: VyGoldButton(label: 'เปิดไพ่ต่อ', onPressed: c.resume),
        );
      case HousesPhase.open:
        if (sel == null) {
          return slot(
            info: Text('หรือแตะไพ่เรื่องที่อยากรู้ก่อนก็ได้', style: Vy.t(15, color: Vy.textSoft)),
            action: VyGoldButton(label: 'เริ่มอ่านจากเรือนวาสนา', onPressed: () => Get.toNamed(RoutePath.houseReadingPage, arguments: 0)),
          );
        }
        return slot(action: VyGoldButton(label: 'อ่านคำทำนายเรื่องนี้', onPressed: () => Get.toNamed(RoutePath.houseReadingPage, arguments: sel)));
    }
  }
}

/// An astrologer's chart behind the cards: soft light, two fine rings, a mark per house,
/// and one gold beam to the house whose turn it is.
class _DialPainter extends CustomPainter {
  final int? active;
  _DialPainter({this.active});

  @override
  void paint(Canvas canvas, Size size) {
    const c = HousesSpreadPage.center;
    final glowRect = Rect.fromCenter(center: c, width: 300, height: 444);
    canvas.drawOval(
        glowRect,
        Paint()
          ..shader = RadialGradient(colors: [Vy.gold.withValues(alpha: 0.2), Vy.violet.withValues(alpha: 0.1), Vy.violet.withValues(alpha: 0)], stops: const [0, 0.55, 1])
              .createShader(glowRect));
    Paint line(Color col, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..color = col;
    canvas.drawOval(Rect.fromCenter(center: c, width: 324, height: 472), line(Vy.gold.withValues(alpha: 0.45), 1));
    canvas.drawOval(Rect.fromCenter(center: c, width: 224, height: 364), line(Vy.gold.withValues(alpha: 0.34), 1));
    canvas.drawOval(Rect.fromCenter(center: c, width: 208, height: 348), line(Colors.white.withValues(alpha: 0.1), 1));
    for (var j = 0; j < 12; j++) {
      final a = (j + 1) * 30 * math.pi / 180;
      final inner = c + Offset(112 * math.sin(a), -182 * math.cos(a));
      final outer = c + Offset(162 * math.sin(a), -236 * math.cos(a));
      final b = a + 15 * math.pi / 180;
      canvas.drawLine(c + Offset(112 * math.sin(b), -182 * math.cos(b)), c + Offset(128 * math.sin(b), -199 * math.cos(b)), line(Vy.gold.withValues(alpha: 0.22), 1));
      if (j == active) {
        final d = outer - inner;
        final u = d / d.distance;
        canvas.drawLine(inner - u * 26, outer - u * 4, line(Vy.gold.withValues(alpha: 0.9), 1.6));
        final p = Path()
          ..moveTo(inner.dx - 4.5, inner.dy)
          ..lineTo(inner.dx, inner.dy - 4.5)
          ..lineTo(inner.dx + 4.5, inner.dy)
          ..lineTo(inner.dx, inner.dy + 4.5)
          ..close();
        canvas.drawPath(p, Paint()..color = Vy.gold);
      } else {
        canvas.drawCircle(inner, 1.8, Paint()..color = Vy.gold.withValues(alpha: 0.7));
      }
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.active != active;
}

class _DashedRect extends CustomPainter {
  final Color color;
  _DashedRect(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)));
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 3.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}
