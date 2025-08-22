import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    required this.icon,
    required this.text,
    this.onPressed,
    this.leading,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget? leading;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.cardColor;

    return MaterialButton(
      elevation: 0.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      disabledColor: color,
      onPressed: onPressed,
      color: color,
      minWidth: 0,
      height: 26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
            width: 20,
            child: leading ?? Icon(icon, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(width: 6),
          MyText(text: text, size: 12),
        ],
      ),
    );
  }
}
