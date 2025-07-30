import 'package:flutter/material.dart' show BuildContext, IconData, Widget;
import 'package:go_router/go_router.dart' show GoRouterState;

class AppRoute {
  final Widget Function(BuildContext context, GoRouterState state)? builder;
  final IconData? icon;
  final Widget? page;
  final String name;
  final String path;

  const AppRoute({
    required this.name,
    required this.path,
    this.builder,
    this.page,
    this.icon,
  });
}
