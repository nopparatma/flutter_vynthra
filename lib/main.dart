import 'package:flutter/material.dart';
import 'package:flutter_vynthra/app/router.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyDz5PEkkiO6MM_j1o5QMd2K5JP8Qn5swRA';

Future<void> main() async {
  final model = GenerativeModel(
    model: 'gemini-2.0-flash-lite',
    apiKey: apiKey,
  );

  const prompt = '''''';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  print('from AI : ${response.text}');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vynthra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: AppRouter.routes,
      initialRoute: RoutePath.homePage,
    );
  }
}
