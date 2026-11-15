import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';
import 'package:vynthra/ui/vy_cards.dart';

import 'houses_controller.dart';

/// The reading of one house. The head is drawn by the app; under the hairline is the HTML from the backend,
/// styled by tag only so a change of wording in the prompt needs no change here.
class HouseReadingPage extends StatefulWidget {
  const HouseReadingPage({super.key});

  @override
  State<HouseReadingPage> createState() => _HouseReadingPageState();
}

class _HouseReadingPageState extends State<HouseReadingPage> {
  final bool _missing = housesReadingMissing();
  late final HousesController c = Get.find<HousesController>();
  late final int i = (Get.arguments as int?) ?? 0;

  @override
  void initState() {
    super.initState();
    // after the first frame: the wheel underneath listens to this and must not rebuild mid-build
    if (!_missing) WidgetsBinding.instance.addPostFrameCallback((_) => c.markRead(i));
  }

  void _goto(int n) => Get.offNamed(RoutePath.houseReadingPage, arguments: n, preventDuplicates: false);

  @override
  Widget build(BuildContext context) {
    if (_missing) return const ColoredBox(color: Vy.ink);
    final card = c.cards[i];
    final html = c.readings[i] ?? '';
    return VyBackground(
      child: SafeArea(
        bottom: false,
        child: Stack(children: [
          Column(children: [
            VyHeader(title: 'คำทำนาย', onBack: () => Get.back()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 160),
                child: VyGlass(
                  radius: 24,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      SizedBox(
                        width: 58,
                        height: 95,
                        child: DecoratedBox(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Vy.gold.withValues(alpha: 0.6))),
                          child: VyCardFace(card: card),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('เรือนที่ ${i + 1} จาก 12', style: Vy.t(14, color: Vy.textMuted)),
                          Text(c.positions[i].name.th, style: Vy.t(22, bold: true, height: 1.3)),
                          Text(houseAbout[i], style: Vy.t(14.5, color: const Color(0xFFEAE6DC))),
                          Text(card.name.th, style: Vy.t(14.5, bold: true, color: Vy.gold)),
                        ]),
                      ),
                    ]),
                    Container(height: 1, margin: const EdgeInsets.only(top: 18), color: Colors.white.withValues(alpha: 0.16)),
                    HtmlWidget(
                      html,
                      textStyle: Vy.t(15, color: const Color(0xFFEAE6DC), height: 1.65),
                      customWidgetBuilder: (el) => el.classes.contains('header') ? const SizedBox.shrink() : null,
                      customStylesBuilder: (el) {
                        switch (el.localName) {
                          case 'h2':
                          case 'h3':
                            return {'font-size': '19px', 'font-weight': '700', 'color': '#F4F1EA', 'margin': '22px 0 8px 0', 'line-height': '1.35'};
                          case 'ul':
                            return {'padding-left': '20px', 'margin': '0'};
                          case 'li':
                            return {'margin-bottom': '8px'};
                          case 'strong':
                            return {'color': '#FFFFFF'};
                          case 'p':
                            return {'margin': '0 0 10px 0'};
                        }
                        return null;
                      },
                    ),
                  ]),
                ),
              ),
            ),
          ]),
          const Positioned(left: 0, right: 0, bottom: 0, child: VyFootFade(height: 196)),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 18,
            child: _Pager(index: i, onPrev: i > 0 ? () => _goto(i - 1) : null, onNext: i < 11 ? () => _goto(i + 1) : () => Get.offNamed(RoutePath.housesEndPage)),
          ),
        ]),
      ),
    );
  }
}

/// One glass capsule to walk the houses: back, where you are among the twelve, on.
class _Pager extends StatelessWidget {
  final int index;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  const _Pager({required this.index, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HousesController>();
    final last = index == 11;
    return SizedBox(
      height: 58,
      child: VyGlass(
        radius: 29,
        tint: 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(children: [
          Opacity(
            opacity: onPrev == null ? 0.32 : 1,
            child: _round(
              onTap: onPrev,
              label: onPrev == null ? 'ไม่มีเรือนก่อนหน้า' : 'อ่านเรือนก่อนหน้า ${c.positions[index - 1].name.th}',
              child: const Icon(Icons.chevron_left_rounded, color: Vy.text),
              gold: false,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // the dots shrink rather than overflow when the last house's wider button takes the room
              FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [
                for (var j = 0; j < 12; j++)
                  Container(
                    width: j == index ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: j == index ? Vy.gold : (j < index ? Vy.gold.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.28)),
                    ),
                  ),
              ])),
              const SizedBox(height: 7),
              Text(last ? 'เรือนสุดท้าย' : 'ถัดไป: ${c.positions[index + 1].name.th}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Vy.t(14, color: Vy.textSoft, height: 1.25)),
            ]),
          ),
          const SizedBox(width: 10),
          last
              ? GestureDetector(
                  onTap: onNext,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: Vy.goldFill, borderRadius: BorderRadius.circular(23)),
                    child: Text('จบการอ่านไพ่', style: Vy.t(15.5, bold: true, color: Vy.onGold)),
                  ),
                )
              : _round(onTap: onNext, label: 'อ่านเรือนถัดไป ${c.positions[index + 1].name.th}', child: const Icon(Icons.chevron_right_rounded, color: Vy.onGold), gold: true),
        ]),
      ),
    );
  }

  Widget _round({required VoidCallback? onTap, required String label, required Widget child, required bool gold}) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gold ? Vy.goldFill : null,
              color: gold ? null : Colors.white.withValues(alpha: 0.06),
              border: gold ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: child,
          ),
        ),
      );
}
