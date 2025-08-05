import 'package:go_router/go_router.dart'
    show GoRoute, GoRouterState, ShellRoute, NoTransitionPage;

import 'package:watchmate_app/router/routes/stream_routes.dart';
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/services/shared_prefs.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:watchmate_app/layouts/home_layout.dart';

abstract class AppRoutes {
  static final stream = StreamRoutes.all;
  static final layout = LayoutRoutes.all;
  static final auth = AuthRoutes.all;

  static String? handle(BuildContext cyx, GoRouterState state) {
    final user = SharedPrefs.instance.getLoggedUser();
    if (user == null) return AuthRoutes.login.path;

    return null;
  }

  static final all = [...auth, ...stream];

  static final shells = [
    ShellRoute(
      builder: (context, state, child) => HomeLayout(child: child),
      redirect: handle,
      routes: layout
          .map(
            (route) => GoRoute(
              path: route.path,
              name: route.name,
              pageBuilder: (ctx, s) => NoTransitionPage(
                child: route.builder?.call(ctx, s) ?? route.page!,
              ),
            ),
          )
          .toList(),
    ),
  ];
}
