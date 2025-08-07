import 'package:cached_network_image/cached_network_image.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;

class CacheImage extends StatelessWidget {
  final double? loaderheight;
  final Widget? placeHolder;
  final Widget? errorWidget;
  final bool showProgress;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit fit;
  final String url;
  const CacheImage({
    this.showProgress = false,
    this.fit = BoxFit.cover,
    required this.url,
    this.loaderheight,
    this.placeHolder,
    this.errorWidget,
    this.height,
    this.color,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = const Size(double.infinity, double.infinity);
    final defaultError = Center(
      child: Image.asset(AppAssets.icons.appIcon, height: 140),
    );

    if (url.isEmpty) return defaultError;

    if (url.startsWith("assets")) {
      return Image.asset(
        url,
        height: height ?? size.height,
        width: width ?? size.height,
        color: color,
        fit: fit,
      );
    }

    if (!url.startsWith("http") &&
        !url.startsWith("https") &&
        File(url).existsSync()) {
      return Image.file(
        File(url),
        height: height ?? size.height,
        width: width ?? size.height,
        color: color,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      fadeOutDuration: const Duration(milliseconds: 200),
      fadeInDuration: const Duration(milliseconds: 200),
      height: height ?? size.height,
      width: width ?? size.height,
      imageUrl: url,
      color: color,
      fit: fit,
      progressIndicatorBuilder: showProgress
          ? (context, url, progress) => Center(
              child: CircularProgressIndicator(value: progress.progress),
            )
          : null,
      placeholder: !showProgress
          ? (context, url) => Center(child: placeHolder)
          : null,
      errorWidget: (context, url, error) {
        return errorWidget ?? defaultError;
      },
    );
  }
}
