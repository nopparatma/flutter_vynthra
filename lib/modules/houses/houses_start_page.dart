import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';
import 'package:vynthra/ui/vy_cards.dart';

import 'houses_controller.dart';

/// Before the cards: read the words (10 s), then hold both thumbs for 3 s.
class HousesStartPage extends StatefulWidget {
  const HousesStartPage({super.key});

  @override
  State<HousesStartPage> createState() => _HousesStartPageState();
}

class _HousesStartPageState extends State<HousesStartPage> with SingleTickerProviderStateMixin {
  static const int readSeconds = 10;

  int _countdown = readSeconds;
  Timer? _timer;
  bool _left = false, _right = false;
  late final AnimationController _hold = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..addListener(() => setState(() {}))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _done();
    });

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
    });
  }

  void _press(bool isLeft, bool down) {
    setState(() => isLeft ? _left = down : _right = down);
    // with a mouse (web) two pads cannot be pressed at once, so one pad held is enough there
    if ((_left && _right) || (kIsWeb && (_left || _right))) {
      _hold.forward();
    } else {
      _hold.reset(); // lifting a thumb starts the count again
    }
  }

  void _done() {
    HapticFeedback.mediumImpact();
    Get.delete<HousesController>(force: true);
    // permanent: the start screen is replaced, and GetX would otherwise dispose the reading with it
    Get.put(HousesController(), permanent: true).begin();
    Get.offNamed(RoutePath.housesSpreadPage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = _countdown > 0;
    final held = _hold.value > 0;
    final secondsLeft = (3 - _hold.value * 3).ceil().clamp(1, 3);

    Widget fan() => Stack(clipBehavior: Clip.none, children: [
          if (held)
            Positioned(
              left: 10,
              top: -50,
              width: 380,
              height: 420,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [Vy.gold.withValues(alpha: 0.42), Vy.gold.withValues(alpha: 0.14), Vy.gold.withValues(alpha: 0)], stops: const [0, 0.55, 1]),
                ),
              ),
            ),
          for (final (rot, dx) in [(-11.0, -74.0), (11.0, 74.0), (0.0, 0.0)])
            Positioned(
              left: 105 + dx,
              top: 18,
              width: 190,
              height: 312,
              child: Transform.rotate(
                angle: rot * 3.14159 / 180,
                child: DecoratedBox(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x8C000000), blurRadius: 40, offset: Offset(0, 16))]),
                  child: const VyCardBack(radius: 14),
                ),
              ),
            ),
        ]);

    return VyBackground(
      child: SafeArea(
        child: Column(children: [
          VyHeader(title: 'ไพ่ 12 เรือน', onBack: () => Get.back()),
          Expanded(
            child: FittedBox(
              child: SizedBox(
                width: 440,
                height: 620,
                child: Column(children: [
                  const SizedBox(height: 34),
                  SizedBox(width: 400, height: 356, child: fan()),
                  const SizedBox(height: 30),
                  Text(held ? 'ไพ่กำลังรับคำอธิษฐาน' : 'ตั้งจิตให้สงบ', style: Vy.t(26, bold: true, height: 1.3)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      held
                          ? 'นึกถึงชีวิตของคุณในใจต่อไป ไพ่ 12 ใบจะเริ่มวางเมื่อครบเวลา'
                          : 'ไพ่ 12 ใบจะวางลง 12 เรือน แต่ละเรือนเล่าชีวิตของคุณหนึ่งด้าน ตั้งแต่วาสนา การเงิน ความรัก ไปจนถึงการงาน',
                      textAlign: TextAlign.center,
                      style: Vy.t(15.5, color: Vy.textMuted, height: 1.6),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: reading
                  ? Column(key: const ValueKey('count'), mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('$_countdown', style: Vy.t(54, color: Vy.gold, height: 1)),
                      const SizedBox(height: 6),
                      Text('อ่านข้อความด้านบน แล้วเตรียมวางนิ้ว', style: Vy.t(15)),
                    ])
                  : Padding(
                      key: const ValueKey('pads'),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        VyThumbPad(progress: _left ? _hold.value : 0, side: 'ซ้าย', onHold: (d) => _press(true, d)),
                        Expanded(
                          child: Semantics(
                            liveRegion: held,
                            child: held
                                ? Column(mainAxisSize: MainAxisSize.min, children: [
                                    Text('$secondsLeft', style: Vy.t(54, color: Vy.gold, height: 1)),
                                    const SizedBox(height: 6),
                                    Text('นิ่งไว้ อย่าเพิ่งยกนิ้ว', textAlign: TextAlign.center, style: Vy.t(15)),
                                  ])
                                : Text('วางนิ้วโป้งสองข้าง\nค้างไว้ 3 วินาที', textAlign: TextAlign.center, style: Vy.t(15.5, height: 1.5)),
                          ),
                        ),
                        VyThumbPad(progress: _right ? _hold.value : 0, side: 'ขวา', onHold: (d) => _press(false, d)),
                      ]),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}
