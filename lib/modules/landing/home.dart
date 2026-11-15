import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'Version ${info.version}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('ไพ่ 12 เรือน', 'ดูภาพรวมชีวิตครบ 12 ด้าน', RoutePath.housesStartPage),
      ('ไพ่ตอบคำถาม', 'ตั้งคำถามและรับคำตอบจากไพ่ 3 ใบ', RoutePath.cardQuestionPage),
      ('ไพ่เสี่ยงทาย', 'ทำนายโชคชะตาและสิ่งที่จะเกิดขึ้นในอนาคต', RoutePath.cardFortunePage),
      ('ไพ่ทั้งหมด', 'รายละเอียดของไพ่ทั้งหมดในสำรับ', RoutePath.viewAllCardsPage),
    ];
    return VyBackground(
      scrim: 0,
      child: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(children: [
                  Image.asset(Vy.logo, width: 236, height: 236, semanticLabel: 'Vynthra'),
                  const SizedBox(height: 14),
                  Text('วันนี้อยากเปิดไพ่แบบไหน',
                      style: Vy.t(22).copyWith(shadows: [Shadow(color: Vy.ink.withValues(alpha: 0.85), blurRadius: 14)])),
                  SizedBox(height: (c.maxHeight - 760).clamp(24, 400)),
                  VyGlass(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Column(children: [
                      for (var i = 0; i < items.length; i++)
                        _MenuRow(title: items[i].$1, subtitle: items[i].$2, last: i == items.length - 1, onTap: () => Get.toNamed(items[i].$3)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Text(_version, style: Vy.t(14, color: const Color(0xFFC9C4B8))),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool last;
  final VoidCallback onTap;

  const _MenuRow({required this.title, required this.subtitle, required this.last, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: Vy.t(22, bold: true, height: 1.3)),
              const SizedBox(height: 2),
              Text(subtitle, style: Vy.t(15, color: Vy.textMuted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Vy.gold),
        ]),
      ),
    );
  }
}
