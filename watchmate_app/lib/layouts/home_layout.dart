import 'package:watchmate_app/common/widgets/custom_bottom_nav_bar.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import "package:watchmate_app/router/routes/layout_routes.dart";
import 'package:watchmate_app/extensions/exports.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key, required this.child});
  final Widget child;

  String _getLocation(BuildContext ctx) {
    return GoRouterState.of(ctx).uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final loc = _getLocation(context);
    final navItem = LayoutRoutes.getByPath(loc);

    return Scaffold(
      appBar: customAppBar(context: context, title: navItem.name, back: false),
      body: child.fadeIn(key: ValueKey(navItem.path), duration: 100.millis),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
