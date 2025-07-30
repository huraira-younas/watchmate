import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_themes.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.not_accessible_rounded,
                color: isDark ? AppColors.darkHint : AppColors.lightHint,
                size: 100,
              ),
              const SizedBox(height: 24),
              MyText(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                text: 'Senpai is Working',
                size: AppConstants.title,
                family: AppFonts.bold,
                isCenter: true,
              ),
              const SizedBox(height: 12),
              MyText(
                text: 'The page you\'re looking for is under development.',
                color: theme.textTheme.bodyMedium?.color,
                size: AppConstants.subtitle,
                isCenter: true,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
