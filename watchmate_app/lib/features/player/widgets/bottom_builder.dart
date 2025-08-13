import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class BottomBuilder extends StatelessWidget {
  const BottomBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return CustomTextField(
      maxLines: 3,
      minLines: 1,
      prefixIcon: const Icon(Icons.title),
      hint: "Enter message",
      suffixIcon: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send, size: 20),
      ).onTap(() {}),
    );
  }
}
