import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:watchmate_app/router/routes/layout_routes.dart';
import 'package:watchmate_app/common/widgets/dialog_boxs.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/features/auth/bloc/events.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final appname = AppConstants.appname;
  final _authBloc = getIt<AuthBloc>();

  Future<void> _delay(Duration elapsed) async {
    final remaining = 4.secs - elapsed;

    if (remaining <= Duration.zero) return;
    await Future.delayed(remaining);
  }

  Future<void> _getUser() async {
    final stopwatch = Stopwatch()..start();

    _authBloc.add(
      AuthGetUser(
        onSuccess: () async {
          await _delay(stopwatch.elapsed);

          if (!mounted) return;
          context.pushReplacement(LayoutRoutes.home.path);
        },
        onError: (error) async {
          await _delay(stopwatch.elapsed);

          if (!mounted) return;
          await errorDialogue(
            message: error.message,
            title: error.title,
            context: context,
          );
          SystemNavigator.pop();
        },
      ),
    );
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
