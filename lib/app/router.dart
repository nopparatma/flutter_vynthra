import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vynthra/modules/card/card_detail.dart';
import 'package:flutter_vynthra/modules/card/view_all_cards.dart';
import 'package:flutter_vynthra/modules/landing/home.dart';
import 'package:get/get.dart';

class RoutePath {
  static const String index = '/';
  static const String splashPage = '/splash';
  static const String homePage = '/home';
  static const String viewAllCardsPage = '/view-all-cards';
  static const String cardDetailPage = '/cards-detail';
}

class AppRouter {
  static final routes = [
    GetPage(
      name: RoutePath.index,
      page: () => Container(),
      // middlewares: [AppMiddleware()],
      children: [
        GetPage(name: RoutePath.splashPage, page: () => Container()),
        GetPage(name: RoutePath.homePage, page: () => const HomePage()),
        GetPage(name: RoutePath.viewAllCardsPage, page: () => const ViewAllCardsPage()),
        GetPage(name: RoutePath.cardDetailPage, page: () => const CardDetailPage()),
      ],
    ),
  ];
}
