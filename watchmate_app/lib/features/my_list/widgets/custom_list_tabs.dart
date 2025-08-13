import 'package:watchmate_app/features/my_list/bloc/bloc.dart';
import 'package:watchmate_app/common/widgets/text_widget.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/constants/app_fonts.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class CustomListTabs extends StatelessWidget {
  final Function(ListType type) onChange;
  final ListType current;
  const CustomListTabs({
    required this.onChange,
    required this.current,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      spacing: 8,
      children: List.generate(ListType.values.length, (idx) {
        final active = current == ListType.values[idx];
        return Chip(
          color: WidgetStateColor.resolveWith(
            (_) => !active
                ? theme.cardColor.withValues(alpha: 0.2)
                : theme.primaryColor,
          ),
          padding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
            side: BorderSide(color: theme.cardColor),
          ),
          label: MyText(
            text: ListType.values[idx].name.capitalize,
            color: !active
                ? theme.textTheme.bodyLarge!.color ?? Colors.black
                : Colors.white,
            family: active ? AppFonts.semibold : AppFonts.regular,
          ),
        ).onTap(() => onChange(ListType.values[idx]));
      }),
    ).padSym(h: AppConstants.padding - 10);
  }
}
