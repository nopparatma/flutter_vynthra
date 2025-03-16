import 'package:flutter/material.dart';
import 'package:flutter_vynthra/app/app_theme.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'app/app_controller.dart';

void main() {
  Get.put(AppController(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vynthra',
      theme: AppTheme.darkTheme,
      getPages: AppRouter.routes,
      initialRoute: RoutePath.splashPage,
    );
  }
}
