import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

AppBar customAppBar({
  List<Widget> actions = const [],
  required BuildContext context,
  bool blackStatusIcons = true,
  bool centerTitle = true,
  Function()? onBackPress,
  String title = "",
  Widget? titleIcon,
  Color? iconColor,
  bool back = true,
  Color? bgColor,
}) {
  final theme = Theme.of(context);
  final color = iconColor ?? theme.iconTheme.color ?? Colors.black;

  return AppBar(
    systemOverlayStyle: blackStatusIcons
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light,
    surfaceTintColor: bgColor ?? theme.appBarTheme.backgroundColor,
    backgroundColor: bgColor ?? theme.appBarTheme.backgroundColor,
    automaticallyImplyLeading: false,
    centerTitle: centerTitle,
    leading: Visibility(
      visible: back,
      child: BackIcon(onBackPress: onBackPress, color: color),
    ),
    actions: actions,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MyText(
          color: theme.textTheme.bodyLarge?.color ?? Colors.black,
          size: AppConstants.titleLarge,
          family: AppFonts.semibold,
          text: title,
        ),
        if (titleIcon != null) titleIcon,
      ],
    ),
  );
}

class BackIcon extends StatelessWidget {
  final Function()? onBackPress;
  final IconData? icon;
  final Color? bgColor;
  final bool isMargin;
  final Color color;

  const BackIcon({
    this.isMargin = true,
    required this.color,
    this.onBackPress,
    this.bgColor,
    super.key,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 40, maxHeight: 40),
      margin: isMargin ? const EdgeInsets.all(8.0) : null,
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.1)),
        color: bgColor ?? theme.cardColor,
        shape: BoxShape.circle,
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: onBackPress ?? () => Navigator.of(context).pop(),
        padding: EdgeInsets.zero,
        elevation: 8,
        child: Icon(icon ?? Icons.arrow_back_rounded, color: color),
      ),
    );
  }
}
