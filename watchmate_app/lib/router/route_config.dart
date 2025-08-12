import 'package:flutter/widgets.dart' show GlobalKey, NavigatorState;
import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'route_observer.dart';
import 'not_found_page.dart';

Iterable<RouteBase> _getRoutes() => AppRoutes.all.map((route) {
  return GoRoute(
    path: route.path,
    name: route.name,
    pageBuilder: route.pageBuilder,
    builder: route.pageBuilder == null
        ? (context, state) {
            if (route.builder == null) return route.page!;
            return route.builder!(context, state);
          }
        : null,
  );
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final appRouter = GoRouter(
  errorBuilder: (_, _) => const NotFoundPage(),
  initialLocation: AuthRoutes.splash.path,
  observers: [GoRouterObserver()],
  navigatorKey: _rootNavigatorKey,
  routes: [..._getRoutes()],
);
