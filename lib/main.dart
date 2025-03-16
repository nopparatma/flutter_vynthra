import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vynthra/app/app_theme.dart';
import 'package:vynthra/app/router.dart';
import 'package:get/get.dart';

import 'app/app_controller.dart';

void main() {
  Get.put(AppController(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: AppTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return GetMaterialApp(
      title: 'Vynthra',
      theme: AppTheme.darkTheme,
      getPages: AppRouter.routes,
      initialRoute: RoutePath.splashPage,
    );
  }
}
