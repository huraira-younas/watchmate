import 'package:watchmate_app/router/routes/layout_routes.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  void _onTap(BuildContext ctx, String loc, int index) {
    final selectedPath = LayoutRoutes.all[index].path;
    if (loc == selectedPath) return;
    ctx.go(selectedPath);
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final selectedIndex = LayoutRoutes.getIndex(loc);
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(LayoutRoutes.all.length, (i) {
          final item = LayoutRoutes.all[i];
          final isSelected = selectedIndex == i;
          final color = isSelected
              ? theme.colorScheme.primary
              : theme.iconTheme.color?.withValues(alpha: 0.6);

          return AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            duration: const Duration(milliseconds: 200),
            width: 90,
            decoration: BoxDecoration(
              color: isSelected
                  ? color!.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: color),
                4.h,
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(item.name),
                ),
              ],
            ),
          ).onTap(
            () => _onTap(context, loc, i),
            behavior: HitTestBehavior.translucent,
          );
        }),
      ),
    );
  }
}
