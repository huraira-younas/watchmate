import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class TitleBuilder extends StatelessWidget {
  final String? coloredText;
  final double bottomMargin;
  final double topMargin;
  final String? subText;
  final double hMargin;
  final Color? color;
  final String title;
  final String desc;

  const TitleBuilder({
    this.bottomMargin = 60,
    this.topMargin = 0.1,
    required this.title,
    required this.desc,
    this.coloredText,
    this.hMargin = 0,
    this.subText,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    final textColor = color ?? theme.colorScheme.primary;
    final greyColor = theme.hintColor.withValues(alpha: 0.9);

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * topMargin,
        bottom: bottomMargin,
        right: 20 + hMargin,
        left: 20 + hMargin,
      ),
      child: Column(
        children: [
          MyText(
            family: AppFonts.semibold,
            size: size.width * 0.06,
            isCenter: true,
            text: title,
          ),
          const SizedBox(height: 10),
          MyText(
            size: AppConstants.subtitle,
            color: greyColor,
            isCenter: true,
            text: desc,
          ),
          if (coloredText != null)
            MyText(text: coloredText!, color: textColor, isCenter: true),
          if (subText != null)
            MyText(text: subText!, family: AppFonts.semibold, isCenter: true),
        ],
      ),
    );
  }
}
