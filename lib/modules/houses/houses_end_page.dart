import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/ui/vy.dart';

import 'houses_controller.dart';

/// The close of the reading: the eclipse that opened the app, and a blessing.
class HousesEndPage extends StatelessWidget {
  const HousesEndPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VyBackground(
      image: Vy.eclipse,
      scrim: 0,
      child: SafeArea(
        child: Column(children: [
          const Spacer(flex: 6),
          Text('ไพ่บอกทางไว้ให้แล้ว', style: Vy.t(28, bold: true, height: 1.3)),
          const SizedBox(height: 12),
          Text('ที่เหลือคือก้าวเดินของคุณเอง\nขอให้พบแต่สิ่งดี ๆ ในทุกเรือนของชีวิต', textAlign: TextAlign.center, style: Vy.t(16.5, color: Vy.textSoft, height: 1.65)),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: VyGlassPair(
              left: 'ดูวงไพ่อีกครั้ง',
              right: 'กลับหน้าแรก',
              onLeft: () => Get.until((r) => r.settings.name == RoutePath.housesSpreadPage),
              onRight: () {
                Get.delete<HousesController>(force: true);
                Get.until((r) => r.settings.name == RoutePath.homePage);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
