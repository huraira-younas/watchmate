import 'package:watchmate_app/common_widget/custom_button.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_themes.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: isDark ? AppColors.darkHint : AppColors.lightHint,
                size: 100,
              ),
              const SizedBox(height: 24),
              MyText(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                text: '404 - Page Not Found',
                size: AppConstants.title,
                family: AppFonts.bold,
                isCenter: true,
              ),
              const SizedBox(height: 12),
              MyText(
                text: 'Oops... The page you\'re looking for doesn\'t exist.',
                color: theme.textTheme.bodyMedium?.color,
                size: AppConstants.subtitle,
                isCenter: true,
              ),
              const SizedBox(height: 30),
              CustomButton(
                onPressed: () => context.go('/'),
                bgColor: theme.primaryColor,
                icon: Icons.home_rounded,
                text: 'Go to Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
