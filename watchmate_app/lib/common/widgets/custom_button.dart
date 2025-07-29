import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final (double, double) padding;
  final Function()? onPressed;
  final double? borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final Color? bgColor;
  final IconData? icon;
  final bool isLoading;
  final double radius;
  final double? width;
  final String text;

  const CustomButton({
    this.padding = (20, 13),
    this.isLoading = false,
    required this.text,
    this.radius = 30,
    this.borderColor,
    this.borderWidth,
    this.onPressed,
    this.textColor,
    this.bgColor,
    this.width,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kWidth = MediaQuery.sizeOf(context).width;

    final finalBgColor = bgColor ?? theme.colorScheme.primary;
    final finalTextColor = onPressed == null
        ? theme.textTheme.bodyLarge!.color!.withValues(alpha: 0.3)
        : textColor ?? theme.colorScheme.onPrimary;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        surfaceTintColor: Colors.transparent,
        minimumSize: Size(width ?? kWidth, 20),
        shadowColor: Colors.transparent,
        backgroundColor: finalBgColor,
        disabledBackgroundColor: theme.colorScheme.surface.withValues(
          alpha: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: borderWidth ?? 2)
              : BorderSide.none,
        ),
        padding: EdgeInsets.symmetric(
          vertical: padding.$2 + 2,
          horizontal: padding.$1,
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: AppConstants.animDur),
        child: isLoading
            ? SizedBox(
                height: 23,
                width: 23,
                child: Center(
                  child: CircularProgressIndicator(
                    color: finalTextColor,
                    strokeWidth: 2.2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: MyText(
                      size: AppConstants.subtitle,
                      color: finalTextColor,
                      family: AppFonts.bold,
                      isCenter: true,
                      text: text,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    Icon(icon!, size: 20, color: finalTextColor),
                  ],
                ],
              ),
      ),
    );
  }
}
