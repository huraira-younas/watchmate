import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class MyTile extends StatelessWidget {
  final VoidCallback onTap;
  final Color? iconColor;
  final IconData icon;
  final String title;

  const MyTile({
    required this.onTap,
    required this.title,
    required this.icon,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      leading: Icon(icon, color: iconColor),
      onTap: onTap,
      title: MyText(
        size: AppConstants.subtitle,
        family: AppFonts.bold,
        text: title,
      ),
    );
  }
}
