import 'package:flutter/material.dart' show Widget, BuildContext;
import 'package:go_router/go_router.dart' show GoRouterState;

class AppRoute {
  final Widget Function(BuildContext context, GoRouterState state)? builder;
  final Widget? page;
  final String name;
  final String path;

  const AppRoute({
    required this.name,
    required this.path,
    this.builder,
    this.page,
  });
}
