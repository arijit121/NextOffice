import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextoffice/core/models/route_model.dart';
import 'package:nextoffice/features/dashboard/presentation/pages/dashboard_page.dart'
    deferred as dashboard;
import 'package:nextoffice/features/docs/presentation/pages/docs_page.dart'
    deferred as docs;
import 'package:nextoffice/features/sheets/presentation/pages/sheets_page.dart'
    deferred as sheets;
import 'package:nextoffice/features/slides/presentation/pages/slides_page.dart'
    deferred as slides;
import 'package:nextoffice/features/file_manager/presentation/pages/file_manager_page.dart'
    deferred as file_manager;
import 'package:nextoffice/features/payment_gateway/presentation/pages/web_view_payment_gateway_status/web_view_payment_gateway_status.dart'
    deferred as web_view_payment_gateway_status;
import 'package:nextoffice/core/services/crash/ui/crash_ui.dart' deferred as crash;
import 'package:nextoffice/core/services/value_handler.dart';
import 'package:nextoffice/shared/ui/molecules/error/error_route_widget.dart'
    deferred as error_route_widget;
import 'package:nextoffice/navigation/router_name.dart';

class RouterManager {
  static final RouterManager _singleton = RouterManager._internal();
  RouterManager._internal();
  static RouterManager getInstance = _singleton;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  List<RouteModel> routeHistory = [];
  int maxHistorySize = 20;

  void _addRoute(GoRouterState route) {
    RouteModel data = RouteModel(
        name: route.name,
        path: route.path,
        uri: route.uri,
        pathParameters: route.pathParameters,
        queryParameters: route.uri.queryParameters,
        extra: route.extra);
    if ((routeHistory.isEmpty || routeHistory.last.uri != data.uri) &&
        ValueHandler.isTextNotEmptyOrNull(data.uri)) {
      routeHistory.add(data);
      if (routeHistory.length > maxHistorySize) {
        routeHistory.removeAt(0);
      }
    }
  }

  GoRouter get router => _router;
  final GoRouter _router = GoRouter(
    observers: <NavigatorObserver>[observer, if (kIsWeb) RouteObserver()],
    initialLocation: RouteName.dashboard,
    routes: <RouteBase>[
      GoRoute(
        name: RouteName.dashboard,
        path: RouteName.dashboard,
        builder: (BuildContext context, GoRouterState state) {
          return dashboard.DashboardPage();
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await dashboard.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.fileManager,
        path: RouteName.fileManager,
        builder: (BuildContext context, GoRouterState state) {
          return file_manager.FileManagerPage();
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await file_manager.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.docs,
        path: RouteName.docs,
        builder: (BuildContext context, GoRouterState state) {
          return docs.DocsPage();
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await docs.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.sheets,
        path: RouteName.sheets,
        builder: (BuildContext context, GoRouterState state) {
          return sheets.SheetsPage();
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await sheets.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.slides,
        path: RouteName.slides,
        builder: (BuildContext context, GoRouterState state) {
          return slides.SlidesPage();
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await slides.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.webViewPaymentStatusWeb,
        path: "${RouteName.webViewPaymentStatusWeb}/:pg_type",
        builder: (BuildContext context, GoRouterState state) {
          if (kIsWeb) {
            return web_view_payment_gateway_status
                .WebViewPaymentGatewayStatus();
          } else {
            return error_route_widget.ErrorRouteWidget();
          }
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await web_view_payment_gateway_status.loadLibrary();
          return null;
        },
      ),
      GoRoute(
        name: RouteName.error,
        path: RouteName.error,
        builder: (BuildContext context, GoRouterState state) {
          if (state.extra is Map<String, dynamic>) {
            return crash.CrashUi(
              errorDetails: state.extra as Map<String, dynamic>,
            );
          } else {
            return error_route_widget.ErrorRouteWidget();
          }
        },
        redirect: (BuildContext context, GoRouterState state) async {
          await crash.loadLibrary();
          return null;
        },
      ),
    ],
    errorBuilder: (context, state) => error_route_widget.ErrorRouteWidget(),
    redirect: (BuildContext context, GoRouterState state) async {
      getInstance._addRoute(state);
      await error_route_widget.loadLibrary();
      return null;
    },
  );

}

class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (RouterManager.getInstance.routeHistory.isNotEmpty) {
      RouterManager.getInstance.routeHistory.removeLast();
    }
  }
}
