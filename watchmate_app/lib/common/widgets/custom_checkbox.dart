import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final Color? borderColor;
  final bool isChecked;
  final bool isCircle;

  const CustomCheckBox({
    required this.isChecked,
    this.isCircle = false,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final outlineColor = borderColor ?? primaryColor;
    final checkColor = theme.colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isCircle ? 3 : 2),
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        border: Border.all(
          color: isChecked ? primaryColor : outlineColor,
          width: 2,
        ),
        color: isChecked && !isCircle ? primaryColor : null,
        borderRadius: BorderRadius.circular(isCircle ? 50 : 5),
      ),
      child: isChecked
          ? isCircle
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                  )
                : Icon(Icons.check, color: checkColor, size: 12)
          : null,
    );
  }
}
