import 'package:watchmate_app/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show Random;
import 'route_observer.dart';
import 'not_found_page.dart';

final GoRouter appRouter = GoRouter(
  errorBuilder: (_, __) => const NotFoundPage(),
  observers: [GoRouterObserver()],
  initialLocation: '/login',
  routes: routes,
  redirect: (context, state) {
    final isLoggedIn = state.uri.toString() == "/login";
    final isLogin = Random().nextInt(4) % 2 == 0;

    if (!isLoggedIn && !isLogin) return '/login';
    if (isLoggedIn && isLogin) return '/';
    return null;
  },
);
