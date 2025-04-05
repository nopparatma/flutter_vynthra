import 'package:vynthra/modules/card/card_detail.dart';
import 'package:vynthra/modules/card/view_all_cards.dart';
import 'package:vynthra/modules/card_fortune/card_fortune.dart';
import 'package:vynthra/modules/card_question/card_question.dart';
import 'package:vynthra/modules/gemini_prediction/gemini_prediction.dart';
import 'package:vynthra/modules/card_standard/card_standard.dart';
import 'package:vynthra/modules/landing/home.dart';
import 'package:vynthra/modules/landing/splash.dart';
import 'package:get/get.dart';

class RoutePath {
  static const String index = '/';
  static const String splashPage = '/splash';
  static const String homePage = '/home';
  static const String cardStandardPage = '/card-standard';
  static const String cardQuestionPage = '/card-question';
  static const String cardFortunePage = '/card-fortune';
  static const String viewAllCardsPage = '/view-all-cards';
  static const String cardDetailPage = '/cards-detail';
  static const String geminiPrediction = '/gemini-prediction';
}

class AppRouter {
  static final routes = [
    CommonGetPage(name: RoutePath.splashPage, page: () => SplashPage()),
    CommonGetPage(name: RoutePath.homePage, page: () => HomePage()),
    CommonGetPage(name: RoutePath.cardStandardPage, page: () => CardStandardPage()),
    CommonGetPage(name: RoutePath.cardQuestionPage, page: () => CardQuestionPage()),
    CommonGetPage(name: RoutePath.cardFortunePage, page: () => CardFortunePage()),
    CommonGetPage(name: RoutePath.viewAllCardsPage, page: () => ViewAllCardsPage()),
    CommonGetPage(name: RoutePath.cardDetailPage, page: () => CardDetailPage()),
    CommonGetPage(name: RoutePath.geminiPrediction, page: () => GeminiPredictionPage()),
  ];
}

/// A wrapper for GetPage that applies common configurations to all routes.
class CommonGetPage extends GetPage {
  /// Creates a CommonGetPage with standard configuration.
  ///
  /// [name] is the route name.
  /// [page] is the widget builder function.
  /// [customMiddlewares] are optional additional middlewares specific to this route.
  /// [requiresAuth] determines if authentication is required for this route.
  /// [requiresConnection] determines if internet connection check should be performed.
  /// [enableAnalytics] determines if analytics tracking is enabled for this route.
  /// [enablePerformanceMonitoring] determines if performance monitoring is enabled.
  /// [binding] dependency injection binding for this route.
  CommonGetPage({
    required super.name,
    required super.page,
    List<GetMiddleware>? customMiddlewares,
    bool requiresAuth = true,
    bool requiresConnection = true,
    bool enableAnalytics = true,
    bool enablePerformanceMonitoring = true,
    super.binding,
  }) : super(
          middlewares: [
            // // Always include logging middleware
            // LoggingMiddleware(),
            //
            // // Optional middleware based on parameters
            // if (enablePerformanceMonitoring) PerformanceMiddleware(),
            // if (enableAnalytics) AnalyticsMiddleware(),
            // if (requiresConnection) ConnectivityMiddleware(),
            // if (requiresAuth) AuthMiddleware(),
            //
            // // Deep link handling
            // DeepLinkMiddleware(),

            // Custom middlewares for this specific route
            ...(customMiddlewares ?? []),
          ],
        );
}
