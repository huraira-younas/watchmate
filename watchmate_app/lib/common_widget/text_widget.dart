import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:math' show max, min;

class MyText extends StatelessWidget {
  final TextOverflow? overflow;
  final Color? backgroundColor;
  final bool shadowEnable;
  final FontWeight weight;
  final TextAlign? align;
  final bool lineThrough;
  final double? height;
  final bool underline;
  final bool isCenter;
  final String family;
  final int? maxLines;
  final Color? color;
  final String text;
  final double size;

  const MyText({
    this.weight = FontWeight.normal,
    this.family = AppFonts.regular,
    this.size = AppConstants.text,
    this.shadowEnable = false,
    this.lineThrough = false,
    this.underline = false,
    this.isCenter = false,
    this.backgroundColor,
    required this.text,
    this.overflow,
    this.maxLines,
    this.height,
    this.align,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor =
        color ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: isCenter ? TextAlign.center : align,
      textScaler: TextScaler.linear(textScaleFactor(context)),
      style: myStyle(
        backgroundColor: backgroundColor,
        shadowEnable: shadowEnable,
        lineThrough: lineThrough,
        underline: underline,
        color: themeColor,
        weight: weight,
        family: family,
        height: height,
        size: size,
      ),
    );
  }
}

TextStyle myStyle({
  FontWeight weight = FontWeight.normal,
  String family = AppFonts.regular,
  double size = AppConstants.text,
  bool shadowEnable = false,
  bool lineThrough = false,
  Color? backgroundColor,
  bool underline = false,
  required Color color,
  double? height,
}) {
  return TextStyle(
    backgroundColor: backgroundColor,
    decorationThickness: 1.5,
    decorationColor: color,
    fontFamily: family,
    fontWeight: weight,
    fontSize: size,
    height: height,
    color: color,
    decoration: underline
        ? TextDecoration.underline
        : lineThrough
        ? TextDecoration.lineThrough
        : null,
    shadows: shadowEnable
        ? [
            Shadow(
              color: color.withValues(alpha: 0.5),
              offset: const Offset(1, 1),
              blurRadius: 1.0,
            ),
          ]
        : null,
  );
}

double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
  final width = MediaQuery.of(context).size.width;
  double val = (width / 1400) * maxTextScaleFactor;
  return max(1, min(val, maxTextScaleFactor));
}
