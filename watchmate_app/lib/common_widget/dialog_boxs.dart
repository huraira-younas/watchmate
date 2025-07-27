import 'package:watchmate_app/common_widget/custom_button.dart';
import 'package:watchmate_app/common_widget/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:flutter/material.dart';

Future<void> errorDialogue({
  required BuildContext context,
  Map<String, String>? action,
  required String message,
  required String title,
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
  final primaryColor = theme.colorScheme.primary;
  final cardColor = theme.cardColor;

  action ??= {"ok": "Okay"};

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        titlePadding: const EdgeInsets.only(
          top: AppConstants.padding + 5,
          right: AppConstants.padding,
          left: AppConstants.padding,
          bottom: 10,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding + 20,
          vertical: AppConstants.padding,
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding,
          vertical: 10,
        ),
        title: Center(
          child: MyText(
            size: AppConstants.title,
            family: AppFonts.bold,
            color: textColor,
            text: title,
          ),
        ),
        content: MyText(
          color: textColor.withValues(alpha: 0.8),
          size: AppConstants.subtitle,
          isCenter: true,
          text: message,
        ),
        actions: <Widget>[
          CustomButton(
            text: action!['ok']!,
            onPressed: () => Navigator.of(context).pop(false),
            bgColor: primaryColor,
          ),
        ],
      );
    },
  );
}

Future<bool> confirmDialogue({
  required BuildContext context,
  required String title,
  required String message,
  Color? confirmColor,
  Map<String, String>? actions,
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
  final primaryColor = confirmColor ?? theme.colorScheme.primary;
  final cardColor = theme.cardColor;

  actions ??= {"confirm": "Confirm", "cancel": "Cancel"};

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        titlePadding: const EdgeInsets.only(
          top: AppConstants.padding + 5,
          right: AppConstants.padding,
          left: AppConstants.padding,
          bottom: 10,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding,
          vertical: AppConstants.padding,
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.padding,
          vertical: 10,
        ),
        title: Center(
          child: MyText(
            size: AppConstants.title,
            family: AppFonts.bold,
            color: textColor,
            text: title,
          ),
        ),
        content: MyText(
          color: textColor.withValues(alpha: 0.8),
          size: AppConstants.subtitle,
          isCenter: true,
          text: message,
        ),
        actions: [
          Column(
            children: [
              CustomButton(
                onPressed: () => Navigator.of(context).pop(true),
                text: actions!['confirm']!,
                bgColor: primaryColor,
                radius: 20,
              ),
              const SizedBox(height: 8),
              CustomButton(
                onPressed: () => Navigator.of(context).pop(false),
                text: actions['cancel']!,
                textColor: primaryColor,
                bgColor: cardColor,
                radius: 20,
              ),
            ],
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}

Future<bool> logoutSheet({
  required BuildContext context,
  required String message,
  required String title,
  String? confirmText,
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
  final primaryColor = theme.colorScheme.primary;
  final cardColor = theme.cardColor;

  return showModalBottomSheet(
    backgroundColor: cardColor,
    context: context,
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            right: AppConstants.padding + 10,
            left: AppConstants.padding + 10,
            top: AppConstants.padding + 10,
            bottom: 5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: MyText(
                  text: title,
                  family: AppFonts.bold,
                  size: AppConstants.title,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              MyText(
                color: textColor.withValues(alpha: 0.6),
                size: AppConstants.subtitle,
                isCenter: true,
                text: message,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: confirmText ?? "Yes, Logout",
                onPressed: () => Navigator.of(context).pop(true),
                textColor: primaryColor,
                bgColor: Colors.transparent,
              ),
              Divider(color: textColor.withValues(alpha: 0.1), height: 10),
              CustomButton(
                onPressed: () => Navigator.of(context).pop(false),
                textColor: textColor,
                bgColor: cardColor,
                text: "Cancel",
              ),
            ],
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}
