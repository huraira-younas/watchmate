import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/router/route_paths.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final appname = AppConstants.appname;

  Future<void> _getUser() async {
    Future.delayed(4.secs, () {
      if (!mounted) return;
      context.pushReplacement(RoutePaths.login);
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final theme = context.theme;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.asset(
              AppAssets.icons.appIcon,
              width: w * 0.5,
            ).hero(AppConstants.appname).fadeIn(),
          ),
          Positioned(
            bottom: 100,
            child: LoadingAnimationWidget.threeRotatingDots(
              color: theme.primaryColor,
              size: 50,
            ).fadeIn().withDelay(1, intervalMs: 1500),
          ),
          Positioned(
            bottom: 40,
            child: MyText(
              key: const ValueKey('appname_text'),
              size: AppConstants.title,
              family: AppFonts.bold,
              text: appname,
            ).fadeIn(duration: 2.secs),
          ),
        ],
      ),
    );
  }
}
