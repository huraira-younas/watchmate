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

  void _onTap(BuildContext ctx, String loc, int index) {
    final selectedPath = LayoutRoutes.all[index].path;
    if (loc == selectedPath) return;
    ctx.go(selectedPath);
  }

  @override
  Widget build(BuildContext context) {
    final loc = _getLocation(context);

    final navItem = LayoutRoutes.getByPath(loc);
    final idx = LayoutRoutes.getIndex(loc);

    final theme = context.theme;
    final sColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: customAppBar(context: context, title: navItem.name, back: false),
      body: child.fadeIn(key: ValueKey(navItem.path), duration: 100.millis),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: sColor,
        selectedItemColor: sColor,
        currentIndex: idx,
        onTap: (index) => _onTap(context, loc, index),
        items: LayoutRoutes.all
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.name,
              ),
            )
            .toList(),
      ),
    );
  }
}
