import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController? controller;
  final Function(int)? onChange;
  final List<String> tabs;
  const CustomTabBar({
    required this.tabs,
    this.controller,
    this.onChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final primaryColor = theme.primaryColor;

    return TabBar(
      dividerColor: theme.highlightColor.withValues(alpha: 0.1),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: primaryColor,
      controller: controller,
      onTap: onChange,
      indicator: UnderlineTabIndicator(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      labelStyle: myStyle(
        size: AppConstants.subtitle,
        family: AppFonts.semibold,
        color: textColor,
      ),
      tabs: List.generate(tabs.length, (idx) => Text(tabs[idx])),
      labelPadding: const EdgeInsets.symmetric(vertical: 12),
      unselectedLabelColor: theme.dividerColor,
      labelColor: primaryColor,
      unselectedLabelStyle: myStyle(
        size: AppConstants.subtitle,
        color: textColor,
      ),
    );
  }
}
