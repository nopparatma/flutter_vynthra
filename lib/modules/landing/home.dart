import 'package:flutter/material.dart';
import 'package:vynthra/app/app_controller.dart';
import 'package:vynthra/app/router.dart';
import 'package:vynthra/widget/common_layout.dart';
import 'package:get/get.dart';

import 'models/feature_option.dart';
import 'widgets/option_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController appController = Get.find<AppController>();
  final ScrollController scrollController = ScrollController();
  late final List<FeatureOption> featureOptions;

  @override
  void initState() {
    super.initState();

    featureOptions = [
      FeatureOption(
        icon: Icons.auto_awesome,
        title: 'ไพ่แบบมาตรฐาน',
        description: 'การอ่านไพ่แบบ 12 ตำแหน่ง',
        onTap: () => Get.toNamed(RoutePath.cardStandardPage),
      ),
      FeatureOption(
        icon: Icons.question_answer,
        title: 'ไพ่ตอบคำถาม',
        description: 'ตั้งคำถามและรับคำตอบจากไพ่ 3 ใบ',
        onTap: () => Get.toNamed(RoutePath.cardQuestionPage),
      ),
      FeatureOption(
        icon: Icons.auto_fix_high,
        title: 'ไพ่เสี่ยงทาย',
        description: 'ทำนายโชคชะตาและสิ่งที่จะเกิดขึ้นในอนาคต',
        onTap: () => Get.toNamed(RoutePath.cardFortunePage),
      ),
      FeatureOption(
        icon: Icons.all_inbox,
        title: 'ไพ่ทั้งหมด',
        description: 'รายละเอียดของไพ่ทั้งหมดในสำรับ',
        onTap: () => Get.toNamed(RoutePath.viewAllCardsPage),
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      scrollController: scrollController,
      body: ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: List.generate(featureOptions.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return SizedBox(height: 16);
                }

                final cardIndex = index ~/ 2;
                return OptionCard(
                  icon: featureOptions[cardIndex].icon,
                  title: featureOptions[cardIndex].title,
                  description: featureOptions[cardIndex].description,
                  onTap: featureOptions[cardIndex].onTap,
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
