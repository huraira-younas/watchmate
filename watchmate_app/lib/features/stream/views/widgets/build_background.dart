import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

class BuildBackground extends StatelessWidget {
  const BuildBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scb = context.theme.scaffoldBackgroundColor;
    final size = context.screenSize;

    return Stack(
      children: <Widget>[
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 0.75, 1.0],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              AppAssets.backgrounds.streamBg,
              fit: BoxFit.cover,
            ),
          ),
        ),

        Positioned(
          top: size.height * 0.18,
          bottom: 0,
          right: 0,
          left: 0,
          child: ClipRRect(
            child: SizedBox(
              height: 100,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: ColoredBox(color: scb.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
