import 'package:watchmate_app/router/route_paths.dart';
import 'package:watchmate_app/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'route_observer.dart';
import 'not_found_page.dart';

final GoRouter appRouter = GoRouter(
  errorBuilder: (_, __) => const NotFoundPage(),
  initialLocation: RoutePaths.login,
  observers: [GoRouterObserver()],
  routes: routes,
  // redirect: (context, state) {
  //   final isLoggedIn = state.uri.toString() == "/login";
  //   final isLogin = true;

  //   if (!isLoggedIn && !isLogin) return RoutePaths.login;
  //   if (isLoggedIn && isLogin) return RoutePaths.home;
  //   return null;
  // },
);
