import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  final Page<dynamic> Function(BuildContext context, GoRouterState state)? pageBuilder;
  final Widget Function(BuildContext context, GoRouterState state)? builder;
  final IconData? icon;
  final Widget? page;
  final String name;
  final String path;

  const AppRoute({
    required this.name,
    required this.path,
    this.pageBuilder,
    this.builder,
    this.page,
    this.icon,
  });
}
