import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class CustomLabelWidget extends StatelessWidget {
  const CustomLabelWidget({
    this.iconSize = 100.0,
    required this.title,
    required this.icon,
    required this.text,
    super.key,
  });

  final double iconSize;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: theme.highlightColor, size: iconSize),
        const SizedBox(height: 24),
        MyText(
          color: theme.textTheme.bodyLarge?.color ?? Colors.white,
          size: AppConstants.title,
          family: AppFonts.bold,
          isCenter: true,
          text: title,
        ),
        const SizedBox(height: 4),
        MyText(
          color: theme.textTheme.bodyMedium?.color,
          size: AppConstants.subtitle,
          isCenter: true,
          text: text,
        ),
      ],
    ).padSym(h: 20);
  }
}
