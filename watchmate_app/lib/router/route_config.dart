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
      builder: (context, state) => route.page,
      name: route.name,
      path: route.path,
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
