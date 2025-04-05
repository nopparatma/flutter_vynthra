import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

/// Base middleware class that provides common functionality for all middlewares
abstract class BaseMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    developer.log('Route requested: $route', name: 'Middleware');
    return super.redirect(route);
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    developer.log('Page called: ${page?.name}', name: 'Middleware');
    return super.onPageCalled(page);
  }
}

/// Middleware for handling authentication
class AuthMiddleware extends BaseMiddleware {
  final String loginRoute;

  AuthMiddleware({this.loginRoute = '/login'});

  @override
  int? get priority => 9;

  @override
  RouteSettings? redirect(String? route) {
    // Example authentication check
    final isAuthenticated = Get.find<AuthService>().isAuthenticated;

    // Public routes that don't require authentication
    final publicRoutes = [
      '/splash',
      '/login',
      '/register',
      '/forgot-password',
    ];

    if (!isAuthenticated && !publicRoutes.contains(route)) {
      return RouteSettings(name: loginRoute);
    }

    return super.redirect(route);
  }
}

/// Middleware for analytics tracking
class AnalyticsMiddleware extends BaseMiddleware {
  @override
  int? get priority => 5;

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null) {
      // Track screen view
      _trackScreenView(page.name);
    }
    return super.onPageCalled(page);
  }

  void _trackScreenView(String screenName) {
    // Implement your analytics tracking here
    // Example with Firebase Analytics:
    // FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    developer.log('Screen view: $screenName', name: 'Analytics');
  }
}

/// Middleware for checking internet connectivity
class ConnectivityMiddleware extends BaseMiddleware {
  final String offlinePage;

  ConnectivityMiddleware({this.offlinePage = '/offline'});

  @override
  int? get priority => 8;

  @override
  RouteSettings? redirect(String? route) {
    // Skip connectivity check for certain routes
    final skipConnectivityRoutes = [
      '/splash',
      '/offline',
      '/settings',
    ];

    if (!skipConnectivityRoutes.contains(route)) {
      final hasConnection = Get.find<ConnectivityService>().hasConnection;
      if (!hasConnection) {
        return RouteSettings(name: offlinePage);
      }
    }

    return super.redirect(route);
  }
}

/// Middleware for logging
class LoggingMiddleware extends BaseMiddleware {
  @override
  int? get priority => 1; // Low priority - should run after other middlewares

  @override
  GetPage? onPageCalled(GetPage? page) {
    developer.log('Page transition: ${page?.name}', name: 'Router');
    return super.onPageCalled(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    developer.log('Page built: ${page.runtimeType}', name: 'Router');
    return super.onPageBuilt(page);
  }

  @override
  void onPageDispose() {
    developer.log('Page disposed', name: 'Router');
    super.onPageDispose();
  }
}

/// Middleware for performance monitoring
class PerformanceMiddleware extends BaseMiddleware {
  @override
  int? get priority => 2;

  late Stopwatch _pageLoadStopwatch;

  @override
  GetPage? onPageCalled(GetPage? page) {
    _pageLoadStopwatch = Stopwatch()..start();
    return super.onPageCalled(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    final loadTime = _pageLoadStopwatch.elapsedMilliseconds;
    developer.log('Page load time: ${loadTime}ms', name: 'Performance');

    // You could send this data to your analytics service
    // for performance monitoring

    return super.onPageBuilt(page);
  }
}

/// Middleware for handling deep links
class DeepLinkMiddleware extends BaseMiddleware {
  @override
  int? get priority => 7;

  @override
  RouteSettings? redirect(String? route) {
    // Process any pending deep links
    final deepLinkService = Get.find<DeepLinkService>();
    final pendingDeepLink = deepLinkService.pendingDeepLink;

    if (pendingDeepLink != null) {
      // Clear the pending deep link
      deepLinkService.clearPendingDeepLink();

      // Return the deep link route
      return RouteSettings(
        name: pendingDeepLink.route,
        arguments: pendingDeepLink.arguments,
      );
    }

    return super.redirect(route);
  }
}

/// Example of how to combine middlewares in your CommonGetPage
///
/// ```dart
/// class CommonGetPage extends GetPage {
///   CommonGetPage({
///     required String name,
///     required GetPageBuilder page,
///     bool requiresAuth = true,
///     bool requiresConnection = true,
///     bool enableAnalytics = true,
///   }) : super(
///     name: name,
///     page: page,
///     middlewares: [
///       LoggingMiddleware(),
///       PerformanceMiddleware(),
///       if (enableAnalytics) AnalyticsMiddleware(),
///       if (requiresConnection) ConnectivityMiddleware(),
///       if (requiresAuth) AuthMiddleware(),
///       DeepLinkMiddleware(),
///     ],
///   );
/// }
/// ```

/// Mock services for example purposes
class AuthService extends GetxService {
  bool get isAuthenticated => true; // Replace with actual authentication logic
}

class ConnectivityService extends GetxService {
  bool get hasConnection => true; // Replace with actual connectivity checking
}

class DeepLinkService extends GetxService {
  DeepLink? pendingDeepLink;

  void clearPendingDeepLink() {
    pendingDeepLink = null;
  }
}

class DeepLink {
  final String route;
  final Map<String, dynamic>? arguments;

  DeepLink(this.route, {this.arguments});
}
