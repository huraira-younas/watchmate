import 'package:watchmate_app/router/routes/auth_routes.dart';
import 'package:watchmate_app/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'route_observer.dart';
import 'not_found_page.dart';

final GoRouter appRouter = GoRouter(
  errorBuilder: (_, __) => const NotFoundPage(),
  initialLocation: AuthRoutes.splash.path,
  observers: [GoRouterObserver()],
  routes: AppRoutes.all.map((route) {
    return GoRoute(
      path: route.path,
      name: route.name,
      builder: (context, state) {
        if (route.builder == null) return route.page!;
        return route.builder!(context, state);
      },
    );
  }).toList(),
  // redirect: (context, state) {
  //   final isLoggedIn = state.uri.toString() == "/login";
  //   final isLogin = true;

  //   if (!isLoggedIn && !isLogin) return RoutePaths.login;
  //   if (isLoggedIn && isLogin) return RoutePaths.home;
  //   return null;
  // },
);
