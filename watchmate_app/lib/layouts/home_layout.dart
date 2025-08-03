import 'package:watchmate_app/common/widgets/custom_bottom_nav_bar.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import "package:watchmate_app/router/routes/layout_routes.dart";
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
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

    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: customAppBar(
        leadingIcon: Image.asset(
          AppAssets.icons.appIcon,
          height: 40,
        ).hero(AppConstants.appname).padOnly(l: 10),
        title: navItem.name,
        centerTitle: false,
        context: context,
        actions: [
          IconButton(
            onPressed: () => context.push(LayoutRoutes.stream.path),
            icon: Icon(
              color: theme.colorScheme.primary,
              LayoutRoutes.stream.icon,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () => getIt<ThemeCubit>().toggleTheme(),
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
          ),
          8.w,
        ],
      ),
      body: child.fadeIn(key: ValueKey(navItem.path), duration: 500.millis),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
