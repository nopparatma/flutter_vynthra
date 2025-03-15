import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vynthra/modules/card/card_detail.dart';
import 'package:flutter_vynthra/modules/card/view_all_cards.dart';
import 'package:flutter_vynthra/modules/gemini_prediction/gemini_prediction.dart';
import 'package:flutter_vynthra/modules/landing/home.dart';
import 'package:flutter_vynthra/modules/landing/splash.dart';
import 'package:get/get.dart';

class RoutePath {
  static const String index = '/';
  static const String splashPage = '/splash';
  static const String homePage = '/home';
  static const String viewAllCardsPage = '/view-all-cards';
  static const String cardDetailPage = '/cards-detail';
  static const String geminiPrediction = '/gemini-prediction';
}

class AppRouter {
  static final routes = [
    GetPage(
      name: RoutePath.index,
      page: () => Container(),
      // middlewares: [AppMiddleware()],
      children: [
        GetPage(name: RoutePath.splashPage, page: () => SplashPage()),
        GetPage(name: RoutePath.homePage, page: () => HomePage()),
        GetPage(name: RoutePath.viewAllCardsPage, page: () => ViewAllCardsPage()),
        GetPage(name: RoutePath.cardDetailPage, page: () => CardDetailPage()),
        GetPage(name: RoutePath.geminiPrediction, page: () => GeminiPredictionPage()),
      ],
    ),
  ];
}
